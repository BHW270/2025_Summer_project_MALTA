/**
 * @file
 * @brief Implementation of Malta2FastSim module
 *
 * @copyright Copyright (c) 2017-2024 CERN and the Allpix Squared authors.
 * This software is distributed under the terms of the MIT License, copied verbatim in the file "LICENSE.md".
 * In applying this license, CERN does not waive the privileges and immunities granted to it by virtue of its status as an
 * Intergovernmental Organization or submit itself to any jurisdiction.
 * SPDX-License-Identifier: MIT
 */

#include "Malta2FastSimModule.hpp"

#include <string>
#include <utility>

#include "core/utils/log.h"

using namespace allpix;

Malta2FastSimModule::Malta2FastSimModule(Configuration& config, Messenger* messenger, std::shared_ptr<Detector> detector)
    : SequentialModule(config, detector), detector_(std::move(detector)), messenger_(messenger) {

    // Allow multithreading of the simulation. Only enabled if this module is thread-safe. See manual for more details.
    // allow_multithreading();

    // Set a default for a configuration parameter, this will be used if no user configuration is provided:
    config_.setDefault<int>("setting", 13);

    // Parsing of the parameter "setting" into a member variable for later use:
    setting_ = config_.get<int>("setting");

    // Messages: register this module with the central messenger to request a certaintype of input messages:
    messenger_->bindSingle<MCParticleMessage>(this, MsgFlags::REQUIRED);
}

void Malta2FastSimModule::initialize() {

    // In this simple case we just print the name of this detector:
    LOG(DEBUG) << "Detector with name " << detector_->getName();
}

void Malta2FastSimModule::run(Event* event) {

    // Messages: Fetch the (previously registered) messages for this event from the messenger:
    auto message = messenger_->fetchMessage<MCParticleMessage>(this, event);

    // Print the name of the detector for which this particular message has been dispatched:
    LOG(DEBUG) << "Picked up " << message->getData().size() << " objects from detector "
               << message->getDetector()->getName();
}

void Malta2FastSimModule::finalize() {
    // Possibly perform finalization of the module - if not, this method does not need to be implemented and can be removed!
    LOG(INFO) << "Successfully finalized!";
}
