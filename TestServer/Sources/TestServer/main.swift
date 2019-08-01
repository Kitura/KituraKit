/*
 * Copyright IBM Corporation 2019
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import Kitura
import HeliumLogger

// Enable logging
HeliumLogger.use(.info)

// Create Controller that contains the TestServer logic
let controller = Controller(userStore: initialStore)

// Add custom coding to support CustomCoderTests
controller.router.encoders[MediaType(type: .application, subType: "custom")] = customEncoder
controller.router.decoders[MediaType(type: .application, subType: "custom")] = customDecoder

// Add an HTTP server and connect it to the router
Kitura.addHTTPServer(onPort: 8080, with: controller.router)

// Start the Kitura runloop (this call never returns)
Kitura.run()
