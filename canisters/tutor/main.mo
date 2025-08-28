
import Text "mo:base/Text";
import Principal "mo:base/Principal";
import Array "mo:base/Array";

import Profile "canister:profile";
import Assessment "canister:assessment";
import VectorIndex "canister:vector";
import LLM "canister:llm";

actor Tutor {
  public type ChatReq = { session: Text; message: Text; topic_id: ?Text };
  public type ChatRes = { reply: Text; citations: [Text]; mastery_delta: ?Float };

  public shared({caller}) func chat(req: ChatReq) : async ChatRes {
    let topic = switch req.topic_id { case (?t) t; case null "general" };
    let ability = switch (await Profile.get_mastery(topic)) { case (?a) a; case null 0.0 };

    // Embed question and retrieve context
    let embs = await LLM.embed([req.message]);
    let top = await VectorIndex.query_topk(embs[0], 3);

    let ctx = Array.foldLeft<{id:Text;score:Float;chunk:Text;url:Text}, Text>(top, "", func(acc, c) {
      acc # "\n- " # c.chunk # " (" # c.url # ")"
    });

    let prompt =
      "You are a patient tutor.\n" #
      "Student ability: " # debug_show(ability) # "\n" #
      "Topic: " # topic # "\n" #
      "Context:" # ctx # "\n\n" #
      "Student: " # req.message # "\nTutor: Provide a guided explanation and one follow-up question.";

    let out = await LLM.promptVariant(#Llama3_1_8B, prompt);

    // Simple mastery delta heuristic (toy)
    let delta : ?Float = ?0.01;

    return { reply = out.text; citations = out.citations; mastery_delta = delta };
  };
}
