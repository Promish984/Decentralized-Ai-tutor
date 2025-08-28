
import Principal "mo:base/Principal";
import HashMap "mo:base/HashMap";
import Iter "mo:base/Iter";
import Nat "mo:base/Nat";
import Nat32 "mo:base/Nat32";
import Nat64 "mo:base/Nat64";
import Text "mo:base/Text";
import Bool "mo:base/Bool";
import Time "mo:base/Time";

actor Profile {
  public type Attempt = {
    item_id : Text;
    correct : Bool;
    ts : Nat64;
    response : Text;
    latency_ms : Nat32;
  };

  public type ProfileInfo = {
    name : Text;
    grade : Text;
    prefs : [Text];
  };

  // Simple in-memory maps (not upgrade-stable; fine for starter)
  stable var _profiles : [(Principal, ProfileInfo)] = [];
  stable var _masteries : [((Principal, Text), Float)] = [];
  stable var _attempts  : [(Principal, Attempt)] = [];

  let profiles = HashMap.HashMap<Principal, ProfileInfo>(10, Principal.equal, Principal.hash);
  let masteries = HashMap.HashMap<(Principal, Text), Float>(32,
    func(a:(Principal,Text), b:(Principal,Text)) : Bool { Principal.equal(a.0,b.0) and Text.equal(a.1,b.1) },
    func(a:(Principal,Text)) : Nat32 { Nat32.fromNat(Principal.hash(a.0) + Text.hash(a.1)) }
  );

  system func preupgrade() {
    _profiles := Iter.toArray(profiles.entries());
    _masteries := Iter.toArray(masteries.entries());
    // flatten attempts
    // Note: attempts kept append-only; in starter we keep only last 100 for space
  };

  system func postupgrade() {
    for ((p,info) in _profiles.vals()) { profiles.put(p, info) };
    for ((k,v) in _masteries.vals()) { masteries.put(k, v) };
    _profiles := []; _masteries := [];
  };

  public shared({caller}) func register_principal(p : Principal) : async Text {
    if (!profiles.contains(p)) {
      profiles.put(p, { name = "Student"; grade = "NA"; prefs = [] });
    };
    return Principal.toText(p);
  };

  public shared({caller}) func set_profile(info : ProfileInfo) : async Bool {
    profiles.put(caller, info);
    true
  };

  public query func get_profile(p : Principal) : async ?ProfileInfo {
    profiles.get(p)
  };

  public query({caller}) func get_mastery(topic : Text) : async ?Float {
    masteries.get((caller, topic))
  };

  public shared({caller}) func set_mastery(topic : Text, val : Float) : async Bool {
    masteries.put((caller, topic), val);
    true
  };

  public shared({caller}) func push_attempt(a : Attempt) : async Bool {
    _attempts := Array.append(_attempts, [(caller, a)]);
    // truncate
    if (Array.size(_attempts) > 100) {
      _attempts := Array.tabulate<(Principal, Attempt)>(100, func i { _attempts[Array.size(_attempts)-100 + i] });
    };
    true
  };

  public query({caller}) func list_attempts(start: ?Nat, limit: Nat) : async [(Attempt)] {
    let all = Array.filter<(Principal, Attempt)>(_attempts, func kv { Principal.equal(kv.0, caller) });
    let s = switch(start){ case(null) 0; case(?x) x };
    let l = if (limit > Nat.fromInt(Array.size(all))) { Nat.fromInt(Array.size(all)) } else { limit };
    let slice = Array.tabulate<Attempt>(Nat.toInt(l), func i { all[s + i].1 });
    slice
  };
}
