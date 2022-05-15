import Buffer "mo:base/Buffer";
import Iter "mo:base/Iter";
import Principal "mo:base/Principal";
import Logger "mo:ic-logger/Logger";
import LoggerCanister "./logger_canister";

actor class TextLogger() = this {
  type LoggerCanisterType = LoggerCanister.LoggerCanister;
  var PAGE_SIZE : Nat = 100;

  stable var record_num = 0;
  var logger_canister_list : Buffer.Buffer<LoggerCanisterType> = Buffer.Buffer<LoggerCanisterType>(0);


  func create_canister() : async () {
    logger_canister_list.add(await LoggerCanister.LoggerCanister(Principal.fromActor(this)));
  };

  public func append(msgs: [Text]) {
    if (record_num == PAGE_SIZE) {
      logger_canister_list.get(logger_canister_list.size() - 1).append(msgs);
      await create_canister();
      record_num := 0;
      return;
    };
    logger_canister_list.get(logger_canister_list.size() - 1).append(msgs);
    record_num += 1;
  };

  public shared func view(from: Nat, to: Nat) : async [Text] {
    assert(to >= from);
    var result : Buffer.Buffer<Text> = Buffer.Buffer<Text>(to - from + 1);
    let start_canister_index = from / PAGE_SIZE;
    let end_canister_index = to / PAGE_SIZE;
    for (index in Iter.range(start_canister_index, end_canister_index)) {
      let f = if (index == 0) {index} else {from - index * PAGE_SIZE};
      let t = if (index == end_canister_index) {to - end_canister_index * PAGE_SIZE } else {PAGE_SIZE - 1};
      let log_text : Logger.View<Text> = await logger_canister_list.get(index).view(f,t);
      if (log_text.messages.size() > 0) {
        for(j in Iter.range(0, log_text.messages.size() - 1)) {
            result.add(log_text.messages[j]);
        };
      };
    };
    result.toArray()
  };
};
