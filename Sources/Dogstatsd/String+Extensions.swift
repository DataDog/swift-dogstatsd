/// Unless explicitly stated otherwise all files in this repository are licensed under the MIT License.
/// This product includes software developed at Datadog (https://www.datadoghq.com/)  Copyright 2022 Datadog, Inc.

import Foundation

extension String {
    var bytesCount: Int {
        return [UInt8](self.utf8).count
    }
}
