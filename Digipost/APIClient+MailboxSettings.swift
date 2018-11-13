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

extension APIClient {
    
    @objc func getMailboxSettings(uri: String, success: @escaping (Dictionary<String, AnyObject>) -> Void, failure: @escaping (_ error: APIError) -> ()) {
        validateFullScope {
            let task = self.urlSessionJSONTask(url: uri,  success: success, failure: failure)
            task.resume()
        }
    }

    @objc func updateMailboxSettings(uri: String, mailboxSettings: Dictionary<String, AnyObject>, success: @escaping () -> Void, failure: @escaping (_ error: APIError) -> ()) {
        validateFullScope {
            let task = self.urlSessionTask(httpMethod.post, url: uri, parameters: mailboxSettings as Dictionary<String, AnyObject>?, success: success,failure: failure)
            task.resume()
        }
    }
}
