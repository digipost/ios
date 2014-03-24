// 
// Copyright (C) Posten Norge AS
// 
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// 
//         http://www.apache.org/licenses/LICENSE-2.0
// 
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#ifndef Digipost_id_h_example_h
#define Digipost_id_h_example_h

#ifdef STAGING

// Remove the .example in this files name to include it in the project
#define OAUTH_SECRET        @"Your staging app secret here"
#define OAUTH_CLIENT_ID     @"Your staging client ID here"
#define OAUTH_REDIRECT_URI  @"http://localhost:7890"

#else
// Remove the .example in this files name to include it in the project
#define OAUTH_SECRET        @"Your production app secret here"
#define OAUTH_CLIENT_ID     @"Your production client ID here"
#define OAUTH_REDIRECT_URI  @"http://localhost:7890"

#endif

#endif