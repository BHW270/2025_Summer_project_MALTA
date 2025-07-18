/**
 * @file
 * @brief Implementation of ROOT data file writer module
 */

#include "Malta2TreeWriterModule.hpp"

#include <TBranchElement.h>
#include <TClass.h>
#include <TProcessID.h>
#include <core/utils/log.h>
#include <core/utils/type.h>
#include <objects/objects.h>
#include <tools/ROOT.h>

#include <core/config/ConfigReader.hpp>
#include <fstream>
#include <objects/Object.hpp>
#include <string>
#include <utility>

using namespace allpix;

Malta2TreeWriterModule::Malta2TreeWriterModule(Configuration& config,
                                               Messenger* messenger,
                                               GeometryManager* geo_mgr
                                               )
: SequentialModule(config), messenger_(messenger), 
    geo_mgr_(geo_mgr) {
  // bind messages
  messenger_->bindMulti<PixelHitMessage>(this, MsgFlags::REQUIRED);

  // Enable multithreading of this module if multithreading is enabled
  allow_multithreading();
}

Malta2TreeWriterModule::~Malta2TreeWriterModule() {}

void Malta2TreeWriterModule::initialize() {

  // set the global time to be 0
  global_time = 500.; // l1id counts from 1
  event_id = 0;

  // Create output file
  output_file_name_ = createOutputFile(
      config_.get<std::string>("file_name", "data"), "root", true);
  output_file_ = std::make_unique<TFile>(output_file_name_.c_str(), "RECREATE");
  output_file_->cd();

  const auto maltaDataDir = output_file_->mkdir("MALTA_DATA");
  for(auto& detector: geo_mgr_->getDetectors()){
    const auto detName = detector->getName();
    LOG(DEBUG)<<"Creating trees for "<<detName;

    const auto maltaTreeDir = maltaDataDir->mkdir(detName.c_str());
    maltaTreeDir->cd();    
    // Create trees to hold Event information
    trees_.emplace(detName.c_str(), std::make_unique<TTree>("MALTA", "MALTA/MALTA2 Data"));

    trees_[detName.c_str()]->Branch("pixel", &pixel_, "pixel/i");
    trees_[detName.c_str()]->Branch("group", &group_, "group/i");
    trees_[detName.c_str()]->Branch("parity", &parity_, "parity/i");
    trees_[detName.c_str()]->Branch("delay", &delay_, "delay/i");
    trees_[detName.c_str()]->Branch("dcolumn", &dcolumn_, "dcolumn/i");
    trees_[detName.c_str()]->Branch("chipbcid", &chipbcid_, "chipbcid/i");
    trees_[detName.c_str()]->Branch("chipid", &chipid_, "chipid/i");
    trees_[detName.c_str()]->Branch("phase", &phase_, "phase/i");
    trees_[detName.c_str()]->Branch("winid", &winid_, "winid/i");
    trees_[detName.c_str()]->Branch("bcid", &bcid_, "bcid/i");
    trees_[detName.c_str()]->Branch("runNumber", &run_, "runNumber/i");
    trees_[detName.c_str()]->Branch("l1id", &l1id_, "l1id/i");
    trees_[detName.c_str()]->Branch("l1idC", &l1idC_, "l1idC/i");  // Valerio
    trees_[detName.c_str()]->Branch("isDuplicate", &isDuplicate_, "isDuplicate/i");
    trees_[detName.c_str()]->Branch("timer", &timer_, "timer/f");

  }

}

void Malta2TreeWriterModule::run(Event* event) {
  using namespace ROOT::Math;
      
  LOG(DEBUG)<<"Event: "<< event_id;
  
  auto root_lock = root_process_lock();

  double time_offset = 130.0; // in ns unit
  double time_spread = 20.0;
  
//  std::shared_ptr<PixelHitMessage> pixels_message{nullptr};
  
  //Check that we actually received pixel hits - we might have none and just received MCParticles!
  try{
      auto hit_messages = messenger_->fetchMultiMessage<PixelHitMessage>(this, event);
      LOG(TRACE)<<"Multi-Message for all planes Received "; //<<pixels_message->getData().size()<<"pixel hits";
      
      //loop over all pixel hit messages
      for(const auto& hit_msg: hit_messages){
        //const auto& detector_name = hit_msg->getDetector()->getName();   // hits from all planes!
        
        // get telescope plane
        const auto& detName =hit_msg->getDetector()->getName();
        const auto& detType = hit_msg->getDetector()->getType();
        LOG(DEBUG)<<"Find detector: "<<detName<<" Detector Type: "<<detType;

        // loop all hits
        for(const auto& hit : hit_msg->getData()){
          auto pixel_hit_x = hit.getPixel().getIndex().x();
          auto pixel_hit_y = hit.getPixel().getIndex().y();
          LOG(TRACE)<<"Find pixel hit at ("<<pixel_hit_x<<", "<<pixel_hit_y<<") on "<<detName;
          
          // for MALTA2 sensor y starts from 288 to 511;
          if(detType == "malta2_simple"){
            pixel_hit_x += 288;   // easy to get confused, please remember x->row, y->col
            LOG(TRACE)<<"Find pixel hit at ("<<pixel_hit_x<<", "<<pixel_hit_y<<") on "<<detName;
          }
          // build Malta word with the hit info
          // pixel, group, parity, delay, dcolumn, chipID=0, phase, winid, bcid, l1id should be used in the next stage analysis

          // set hit
          setHit(pixel_hit_x, pixel_hit_y);

          // lambda for smearing the Monte Carlo truth time offset
          auto time_smearing = [&](auto rms){
            double time = allpix::normal_distribution<double>(0, rms)(event->getRandomEngine());
            return time;
          };
          double arrive_time = hit.getLocalTime() + time_offset + time_smearing(time_spread);
          //set tag (timing info w.r.t trigger)
          
          // l1id 500ns window -> 2MHz
          setTag(arrive_time, global_time);
          
          // fill trees
          trees_[detName.c_str()]->Fill();
          

        }


      }
      

  }catch(const MessageNotFoundException&){
    LOG(WARNING)<<"MessageNotFoundException found!";
  }

  //update the global time 
  global_time += 500.;
  event_id++;
}

void Malta2TreeWriterModule::finalize() {
  LOG(TRACE) << "Writing objects to file";
  output_file_->cd();

  // Create main config directory
  TDirectory* config_dir = output_file_->mkdir("config");
  config_dir->cd();

  // Get the config manager
  ConfigManager* conf_manager = getConfigManager();

  // Save the main configuration to the output file
  auto* global_dir = config_dir->mkdir("Allpix");
  LOG(TRACE) << "Writing global configuration";

  // Loop over all values in the global configuration
  for (auto& key_value : conf_manager->getGlobalConfiguration().getAll()) {
    global_dir->WriteObject(&key_value.second, key_value.first.c_str());
  }

  // Save the instance configuration to the output file
  for (const auto& config : conf_manager->getInstanceConfigurations()) {
    // Create a new directory per section, using the unique module name
    auto unique_name = config.getName();
    auto identifier = config.get<std::string>("identifier");
    if (!identifier.empty()) {
      unique_name += ":";
      unique_name += identifier;
    }
    auto* section_dir = config_dir->mkdir(unique_name.c_str());
    LOG(TRACE) << "Writing configuration for: " << unique_name;

    // Loop over all values in the section
    for (auto& key_value : config.getAll()) {
      // Skip the identifier
      if (key_value.first == "identifier") {
        continue;
      }
      section_dir->WriteObject(&key_value.second, key_value.first.c_str());
    }
  }

  // Save the detectors to the output file
  auto* detectors_dir = output_file_->mkdir("detectors");
  auto* models_dir = output_file_->mkdir("models");
  for (auto& detector : geo_mgr_->getDetectors()) {
    detectors_dir->cd();
    LOG(TRACE) << "Writing detector configuration for: " << detector->getName();
    auto* detector_dir = detectors_dir->mkdir(detector->getName().c_str());

    auto position = detector->getPosition();
    detector_dir->WriteObject(&position, "position");
    auto orientation = detector->getOrientation();
    detector_dir->WriteObject(&orientation, "orientation");

    // Store the detector model
    // NOTE We save the model for every detector separately since parameter
    // overloading might have changed it
    std::string model_name =
        detector->getModel()->getType() + "_" + detector->getName();
    detector_dir->WriteObject(&model_name, "type");
    models_dir->cd();
    auto* model_dir = models_dir->mkdir(model_name.c_str());

    // Get all sections of the model configuration (maon config plus support
    // layers):
    auto model_configs = detector->getModel()->getConfigurations();
    std::map<std::string, int> count_configs;
    for (auto& model_config : model_configs) {
      auto* model_config_dir = model_dir;
      if (!model_config.getName().empty()) {
        model_config_dir = model_dir->mkdir(
            (model_config.getName() + "_" +
             std::to_string(count_configs[model_config.getName()]))
                .c_str());
        count_configs[model_config.getName()]++;
      }

      for (auto& key_value : model_config.getAll()) {
        model_config_dir->WriteObject(&key_value.second,
                                      key_value.first.c_str());
      }
    }
  }

  // Finish writing to output file
  output_file_->Write();
 
  // reset the global time 
  global_time = 0.;
  event_id = 0;
}

void Malta2TreeWriterModule::setHit(uint32_t row, uint32_t col){

  row = row&0x1FF;
  col = col&0x1FF;
  dcolumn_ = col>>1;
  group_ = row>>4;
  uint32_t rest = row -(group_<<4);
  parity_ = (rest>7 ? 1:0);
  uint32_t pbit = (row%8) + (col%2 == 1?8:0);
  pixel_ = 1 <<pbit;  // MALTA style for hit pixel in a 2*8 group: 0->2^0; 15->2^15

  // arbitray settings for timing, optional for modification
  delay_ = 0;

}

// assume continuous frames 
void Malta2TreeWriterModule::setTag(double arrive_time, double g_time){
  // chipid set to be 0 by default
  chipid_ = 0;
  chipbcid_ = 0; // feature currently not used/broken in the chip, set to be zero

  
  uint32_t bcid_size = 64;
  uint32_t winid_size = 8;
  uint32_t phase_size = 8;
  // bcid period 25ns  // mark here: may cause some timing uncertainty 
  bcid_ = static_cast<uint32_t>(arrive_time/25) % bcid_size;
  auto left = static_cast<double>(std::fmod(arrive_time, 25));
  // winid period 3.125ns
  winid_ = static_cast<uint32_t>(left/3.125) % winid_size;
  left = static_cast<double>(std::fmod(left, 3.125));
  // phase period 3.125/8.
  phase_ = static_cast<uint32_t>(left/0.390625) % phase_size;

  // set the l1id  time window 500ns
  uint32_t l1id_size = 4096;
  l1id_ = static_cast<uint32_t>(g_time/500) % l1id_size; 
  
}
