import Logger "mo:ic-logger/Logger";

actor class LoggerCanister(installer: Principal) {
    stable let owner : Principal = installer;
    stable var state : Logger.State<Text> = Logger.new<Text>(0, null);
    let logger = Logger.Logger<Text>(state);

    public shared query (msg) func view(from: Nat, to: Nat) : async Logger.View<Text> {
        logger.view(from, to)
    };

    public shared (msg) func append(msgs: [Text]) {
    logger.append(msgs);
  };
}