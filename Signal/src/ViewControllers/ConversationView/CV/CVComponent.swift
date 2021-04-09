//
//  Copyright (c) 2021 Open Whisper Systems. All rights reserved.
//

import Foundation

// Represents some _renderable_ portion of an Conversation View item.
// It could be the entire item or some part thereof.
public protocol CVComponent: class {

    var itemModel: CVItemModel { get }

    func buildComponentView(componentDelegate: CVComponentDelegate) -> CVComponentView

    func configureForRendering(componentView: CVComponentView,
                               cellMeasurement: CVCellMeasurement,
                               componentDelegate: CVComponentDelegate)

    // This method should only be called on workQueue.
    func measure(maxWidth: CGFloat, measurementBuilder: CVCellMeasurement.Builder) -> CGSize

    // return true IFF the tap was handled.
    func handleTap(sender: UITapGestureRecognizer,
                   componentDelegate: CVComponentDelegate,
                   componentView: CVComponentView,
                   renderItem: CVRenderItem) -> Bool

    func findLongPressHandler(sender: UILongPressGestureRecognizer,
                              componentDelegate: CVComponentDelegate,
                              componentView: CVComponentView,
                              renderItem: CVRenderItem) -> CVLongPressHandler?

    func findPanHandler(sender: UIPanGestureRecognizer,
                        componentDelegate: CVComponentDelegate,
                        componentView: CVComponentView,
                        renderItem: CVRenderItem,
                        messageSwipeActionState: CVMessageSwipeActionState) -> CVPanHandler?
    func startPanGesture(sender: UIPanGestureRecognizer,
                         panHandler: CVPanHandler,
                         componentDelegate: CVComponentDelegate,
                         componentView: CVComponentView,
                         renderItem: CVRenderItem,
                         messageSwipeActionState: CVMessageSwipeActionState)
    func handlePanGesture(sender: UIPanGestureRecognizer,
                          panHandler: CVPanHandler,
                          componentDelegate: CVComponentDelegate,
                          componentView: CVComponentView,
                          renderItem: CVRenderItem,
                          messageSwipeActionState: CVMessageSwipeActionState)

    func cellDidLayoutSubviews(componentView: CVComponentView,
                               renderItem: CVRenderItem,
                               messageSwipeActionState: CVMessageSwipeActionState)

    func cellDidBecomeVisible(componentView: CVComponentView,
                              renderItem: CVRenderItem,
                              messageSwipeActionState: CVMessageSwipeActionState)
}

// MARK: -

public protocol CVRootComponent: CVComponent {

    var componentState: CVComponentState { get }

    var cellReuseIdentifier: CVCellReuseIdentifier { get }

    func configure(cellView: UIView,
                   cellMeasurement: CVCellMeasurement,
                   componentDelegate: CVComponentDelegate,
                   cellSelection: CVCellSelection,
                   messageSwipeActionState: CVMessageSwipeActionState,
                   componentView: CVComponentView)

    var isDedicatedCell: Bool { get }
}

// MARK: -

public protocol CVAccessibilityComponent: CVComponent {
    var accessibilityDescription: String { get }

    // TODO: We should have a getter for "accessiblity actions",
    //       presumably as [CVMessageAction].
}

// MARK: -

// TODO: There has to be a better way to do this.
public class CVMeasurementObject: Equatable {

    // MARK: - Equatable

    public static func == (lhs: CVMeasurementObject, rhs: CVMeasurementObject) -> Bool {
        true
    }
}

// CVCellMeasurement captures the measurement state from the load.
// This lets us pin cell views to their measured sizes.  This is
// necessary because some UIViews (like UIImageView) set up
// layout contraints based on their content that we want to override.
public struct CVCellMeasurement: Equatable {

    public typealias Measurement = ManualStackMeasurement
    public typealias ObjectType = CVMeasurementObject

    let cellSize: CGSize
    private let sizes: [String: CGSize]
    private let values: [String: CGFloat]
    private let measurements: [String: Measurement]
    private let objects: [String: ObjectType]

    public class Builder {
        var cellSize: CGSize = .zero
        private var sizes = [String: CGSize]()
        private var values = [String: CGFloat]()
        private var measurements = [String: Measurement]()
        private var objects = [String: ObjectType]()

        func build() -> CVCellMeasurement {
            CVCellMeasurement(cellSize: cellSize,
                              sizes: sizes,
                              values: values,
                              measurements: measurements,
                              objects: objects)
        }

        func setSize(key: String, size: CGSize) {
            owsAssertDebug(sizes[key] == nil)

            sizes[key] = size
        }

        func setValue(key: String, value: CGFloat) {
            owsAssertDebug(values[key] == nil)

            values[key] = value
        }

        func setMeasurement(key: String, value: Measurement) {
            owsAssertDebug(measurements[key] == nil)

            measurements[key] = value
        }

        func setObject(key: String, value: ObjectType) {
            owsAssertDebug(measurements[key] == nil)

            objects[key] = value
        }
    }

    func size(key: String) -> CGSize? {
        sizes[key]
    }

    func value(key: String) -> CGFloat? {
        values[key]
    }

    func measurement(key: String) -> Measurement? {
        measurements[key]
    }

    func object<T>(key: String) -> T? {
        guard let value = objects[key] else {
            return nil
        }
        guard let object = value as? T else {
            owsFailDebug("Missing object: \(key)")
            return nil
        }
        return object
    }

    public var debugDescription: String {
        "[cellSize: \(cellSize), sizes: \(sizes), values: \(values), measurements: \(measurements)]"
    }

    public func debugLog() {
        Logger.verbose("cellSize: \(cellSize)")
        Logger.verbose("sizes: \(sizes)")
        Logger.verbose("values: \(values)")
        Logger.verbose("measurements: \(measurements)")
    }
}

// MARK: -

@objc
public class CVComponentBase: NSObject {
    @objc
    public let itemModel: CVItemModel

    init(itemModel: CVItemModel) {
        self.itemModel = itemModel
    }

    public func handleTap(sender: UITapGestureRecognizer,
                          componentDelegate: CVComponentDelegate,
                          componentView: CVComponentView,
                          renderItem: CVRenderItem) -> Bool {
        Logger.verbose("Ignoring tap.")
        return false
    }

    public func findLongPressHandler(sender: UILongPressGestureRecognizer,
                                     componentDelegate: CVComponentDelegate,
                                     componentView: CVComponentView,
                                     renderItem: CVRenderItem) -> CVLongPressHandler? {
        Logger.verbose("Ignoring long press.")
        return nil
    }

    public func findPanHandler(sender: UIPanGestureRecognizer,
                               componentDelegate: CVComponentDelegate,
                               componentView: CVComponentView,
                               renderItem: CVRenderItem,
                               messageSwipeActionState: CVMessageSwipeActionState) -> CVPanHandler? {
        Logger.verbose("Ignoring pan.")
        return nil
    }

    public func startPanGesture(sender: UIPanGestureRecognizer,
                                panHandler: CVPanHandler,
                                componentDelegate: CVComponentDelegate,
                                componentView: CVComponentView,
                                renderItem: CVRenderItem,
                                messageSwipeActionState: CVMessageSwipeActionState) {
        owsFailDebug("No pan in progress.")
    }

    public func handlePanGesture(sender: UIPanGestureRecognizer,
                                 panHandler: CVPanHandler,
                                 componentDelegate: CVComponentDelegate,
                                 componentView: CVComponentView,
                                 renderItem: CVRenderItem,
                                 messageSwipeActionState: CVMessageSwipeActionState) {
        owsFailDebug("No pan in progress.")
    }

    public func cellDidLayoutSubviews(componentView: CVComponentView,
                                      renderItem: CVRenderItem,
                                      messageSwipeActionState: CVMessageSwipeActionState) {
        // Do nothing.
    }

    public func cellDidBecomeVisible(componentView: CVComponentView,
                                     renderItem: CVRenderItem,
                                     messageSwipeActionState: CVMessageSwipeActionState) {
        // Do nothing.
    }

    var isShowingSelectionUI: Bool {
        itemModel.itemViewState.isShowingSelectionUI
    }
}

// MARK: -

extension CVComponentBase: CVNode {
    public var thread: TSThread { itemModel.thread }
    public var interaction: TSInteraction { itemModel.interaction }
    public var componentState: CVComponentState { itemModel.componentState }
    public var itemViewState: CVItemViewState { itemModel.itemViewState }
    public var messageCellType: CVMessageCellType { componentState.messageCellType }
    public var conversationStyle: ConversationStyle { itemModel.conversationStyle }
    public var mediaCache: CVMediaCache { itemModel.mediaCache }
    public var isDarkThemeEnabled: Bool { conversationStyle.isDarkThemeEnabled }

    public var isGroupThread: Bool {
        thread.isGroupThread
    }

    public var isBorderless: Bool {
        if componentState.isJumbomojiMessage {
            return true
        }
        if componentState.isBorderlessBodyMediaMessage {
            return true
        }

        switch messageCellType {
        case .stickerMessage:
            return true
        default:
            return false
        }
    }

    var isTextOnlyMessage: Bool { messageCellType == .textOnlyMessage }

    // This var should only be accessed for messages.
    var bubbleColorForMessage: UIColor {
        guard let message = interaction as? TSMessage else {
            owsFailDebug("Invalid interaction.")
            return conversationStyle.bubbleColor(isIncoming: true)
        }
        return conversationStyle.bubbleColor(message: message)
    }
}

// MARK: -

extension CVComponentBase {
    public func buildBlurView(conversationStyle: ConversationStyle) -> UIVisualEffectView {
        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
        let blurOverlay = UIView()
        blurOverlay.backgroundColor = conversationStyle.isDarkThemeEnabled ? .ows_blackAlpha40 : .ows_whiteAlpha60
        blurView.contentView.addSubview(blurOverlay)
        blurOverlay.autoPinEdgesToSuperviewEdges()

        return blurView
    }
}

// MARK: -

// Used for rendering some portion of an Conversation View item.
// It could be the entire item or some part thereof.
@objc
public protocol CVComponentView {

    var rootView: UIView { get }

    var isDedicatedCellView: Bool { get set }

    func setIsCellVisible(_ isCellVisible: Bool)

    func reset()
}

// MARK: -

public struct CVComponentAndView {
    let key: CVComponentKey
    let component: CVComponent
    let componentView: CVComponentView
}

// MARK: -

public enum CVComponentKey: CustomStringConvertible, CaseIterable {
    // These components appear in CVComponentMessage.
    case bodyText
    case bodyMedia
    case senderName
    case senderAvatar
    case footer
    case sticker
    case quotedReply
    case linkPreview
    case reactions
    case viewOnce
    case audioAttachment
    case genericAttachment
    case contactShare
    case bottomButtons
    case sendFailureBadge

    case systemMessage
    case dateHeader
    case unreadIndicator
    case typingIndicator
    case threadDetails
    case failedOrPendingDownloads

    public var description: String {
        switch self {
        case .bodyText:
            return ".bodyText"
        case .bodyMedia:
            return ".bodyMedia"
        case .senderName:
            return ".senderName"
        case .senderAvatar:
            return ".senderAvatar"
        case .footer:
            return ".footer"
        case .sticker:
            return ".sticker"
        case .quotedReply:
            return ".quotedReply"
        case .linkPreview:
            return ".linkPreview"
        case .reactions:
            return ".reactions"
        case .viewOnce:
            return ".viewOnce"
        case .audioAttachment:
            return ".audioAttachment"
        case .genericAttachment:
            return ".genericAttachment"
        case .contactShare:
            return ".contactShare"
        case .bottomButtons:
            return ".bottomButtons"
        case .systemMessage:
            return ".systemMessage"
        case .dateHeader:
            return ".dateHeader"
        case .unreadIndicator:
            return ".unreadIndicator"
        case .typingIndicator:
            return ".typingIndicator"
        case .threadDetails:
            return ".threadDetails"
        case .failedOrPendingDownloads:
            return ".failedOrPendingDownloads"
        case .sendFailureBadge:
            return ".sendFailureBadge"
        }
    }

    var asKey: String { description }
}
