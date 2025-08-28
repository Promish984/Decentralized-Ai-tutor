
import Text "mo:base/Text";
import Array "mo:base/Array";
import Int "mo:base/Int";
import Nat "mo:base/Nat";

actor LLM {
  public type PromptVariant = { #Llama3_1_8B; #Small };

  public type Out = { text: Text; citations: [Text] };

  public func promptVariant(v: PromptVariant, prompt: Text) : async Out {
    let model = switch v { case (#Llama3_1_8B) "Llama3.1-8B"; case (#Small) "Small" };
    { text = "🤖 [" # model # "] " # prompt # "\n(This is a mock LLM response—swap with a real LLM canister in prod.)";
      citations = [] }
  };

  public func embed(texts: [Text]) : async [[Float]] {
    // toy embeddings: deterministic small vectors
    Array.map<Text, [Float]>(texts, func t {
      let h = Int.abs(Text.hash(t));
      [Float.fromInt(h % 97), Float.fromInt((h/7) % 89), Float.fromInt(Text.size(t))]
    })
  };
}
