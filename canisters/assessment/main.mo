
import HashMap "mo:base/HashMap";
import Nat32 "mo:base/Nat32";
import Text "mo:base/Text";
import Bool "mo:base/Bool";

actor Assessment {
  public type Item = {
    id: Text;
    stem: Text;
    choices: [Text];
    key: Nat32;
    topic_id: Text;
    difficulty: Float;
  };

  let items = HashMap.HashMap<Text, Item>(64, Text.equal, Text.hash);

  public func upsert_item(it: Item) : async Bool {
    items.put(it.id, it);
    true
  };

  public query func grade_mcq(id: Text, answer: Nat32) : async Bool {
    switch (items.get(id)) {
      case (?it) { answer == it.key };
      case null { false };
    }
  };

  public query func get_next_item(req: { topic_id: Text; ability: Float }) : async ?{ id: Text; stem: Text; choices: [Text] } {
    // naive: pick first by topic; in production apply IRT/Elo matching
    for ((_, it) in items.entries()) {
      if (Text.equal(it.topic_id, req.topic_id)) {
        return ?{ id = it.id; stem = it.stem; choices = it.choices };
      }
    };
    null
  };
}
