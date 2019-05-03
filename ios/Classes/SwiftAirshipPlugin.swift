import Flutter
import UIKit
import AirshipKit

public class SwiftAirshipPlugin: NSObject, FlutterPlugin {

    let jsonEncoder = JSONEncoder()

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "com.airship.flutter/airship",
                                           binaryMessenger: registrar.messenger())

        let instance = SwiftAirshipPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)

        UAirship.takeOff()
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getChannelId":
            getChannelId(call, result: result)
        case "setUserNotificationsEnabled":
            setUserNotificationsEnabled(call, result: result)
        case "getUserNotificationsEnabled":
            getUserNotificationsEnabled(call, result: result)
        case "addTags":
            addTags(call, result: result)
        case "removeTags":
            removeTags(call, result: result)
        case "getTags":
            getTags(call, result: result)
        case "setNamedUser":
            setNamedUser(call, result: result)
        case "getNamedUser":
            getNamedUser(call, result: result)
        case "getInboxMessages":
            getInboxMessages(call, result: result)
        default:
            result(FlutterError(code:"UNAVAILABLE",
                message:"Unknown method: \(call.method)",
                details:nil))
        }
    }

    private func getChannelId(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        result(UAirship.push()?.channelID)
    }

    private func setUserNotificationsEnabled(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let enable = call.arguments as! Bool
        UAirship.push()?.userPushNotificationsEnabled = enable
        UAirship.push()?.updateRegistration()
        result(nil)
    }

    private func getUserNotificationsEnabled(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        result(UAirship.push()?.userPushNotificationsEnabled)
    }

    private func addTags(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let tags = call.arguments as! [String]
        UAirship.push()?.addTags(tags)
        UAirship.push()?.updateRegistration()
        result(nil)
    }

    private func removeTags(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let tags = call.arguments as! [String]
        UAirship.push()?.removeTags(tags)
        UAirship.push()?.updateRegistration()
        result(nil)
    }

    private func getTags(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        result(UAirship.push()?.tags)
    }

    private func setNamedUser(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let namedUser = call.arguments as? String
        UAirship.namedUser()?.identifier = namedUser
        result(nil)
    }

    private func getNamedUser(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        result(UAirship.namedUser()?.identifier)
    }


    private func getInboxMessages(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let messages = UAirship.inbox()?.messageList.messages.map { (message) -> String in
            var payload = ["title": message.title,
                           "message_id": message.messageID,
                           "sent_date": UAUtils.isoDateFormatterUTCWithDelimiter().string(from: message.messageSent),
                           "is_read": message.unread] as [String : Any]


            if let icons = message.rawMessageObject["icons"] as? [String:Any] {
                if let listIcon = icons["list_icon"] {
                    payload["list_icon"] = listIcon
                }
            }

            if let expiration = message.messageExpiration {
                payload["expiration_date"] = UAUtils.isoDateFormatterUTCWithDelimiter().string(from: expiration)
            }

            let data = try! JSONSerialization.data(withJSONObject: payload as Any, options: [])
            return String(data: data, encoding: .utf8)!
        }

        result(messages)
    }
}
