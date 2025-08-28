
import React, { useState } from "react";
import { HttpAgent, Actor } from "@dfinity/agent";

// Minimal candid for Tutor.canister
const idlFactory = ({ IDL }) => {
  const ChatReq = IDL.Record({ session: IDL.Text, message: IDL.Text, topic_id: IDL.Opt(IDL.Text) });
  const ChatRes = IDL.Record({ reply: IDL.Text, citations: IDL.Vec(IDL.Text), mastery_delta: IDL.Opt(IDL.Float64) });
  return IDL.Service({ chat: IDL.Func([ChatReq], [ChatRes], []) });
};

// NOTE: during `dfx deploy`, replace this with the actual canister ID or import from declarations.
const TUTOR_CANISTER_ID = "bw4dl-smaaa-aaaaa-qaacq-cai";

async function makeTutorActor() {
  const agent = new HttpAgent();
  if (location.hostname === "127.0.0.1" || location.hostname === "localhost") {
    await agent.fetchRootKey();
  }
  return Actor.createActor(idlFactory as any, { agent, canisterId: TUTOR_CANISTER_ID });
}

export default function App() {
  const [input, setInput] = useState("");
  const [topic, setTopic] = useState("algebra");
  const [msgs, setMsgs] = useState<{ role: string; text: string }[]>([]);
  const [busy, setBusy] = useState(false);

  async function send() {
    if (!input.trim()) return;
    setBusy(true);
    try {
      const actor: any = await makeTutorActor();
      const res = await actor.chat({ session: "s1", message: input, topic_id: [topic] });
      setMsgs((m) => [...m, { role: "you", text: input }, { role: "tutor", text: res.reply }]);
      setInput("");
    } finally {
      setBusy(false);
    }
  }

  return (
    <div style={{ maxWidth: 800, margin: "40px auto", fontFamily: "Inter, system-ui, sans-serif" }}>
      <h1>Decentralized AI Tutor (ICP)</h1>
      <p>Local demo using mock LLM canister. Deploy with <code>dfx</code> and replace canister IDs.</p>

      <label>Topic:&nbsp;
        <input value={topic} onChange={(e)=>setTopic(e.target.value)} />
      </label>

      <div style={{ border: "1px solid #ddd", padding: 16, borderRadius: 12, minHeight: 150, marginTop: 12 }}>
        {msgs.map((m,i)=>(<p key={i}><b>{m.role}:</b> {m.text}</p>))}
      </div>

      <div style={{ display: "flex", gap: 8, marginTop: 12 }}>
        <input
          style={{ flex: 1, padding: 12, borderRadius: 10, border: "1px solid #ccc" }}
          placeholder="Ask a question..."
          value={input}
          onChange={(e)=>setInput(e.target.value)}
          onKeyDown={(e)=> e.key === "Enter" && send()}
        />
        <button onClick={send} disabled={busy} style={{ padding: "12px 16px", borderRadius: 10 }}>
          {busy ? "Thinking..." : "Send"}
        </button>
      </div>
    </div>
  );
}
