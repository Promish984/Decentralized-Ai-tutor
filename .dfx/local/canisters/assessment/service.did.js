export const idlFactory = ({ IDL }) => {
  const Item = IDL.Record({
    'id' : IDL.Text,
    'key' : IDL.Nat32,
    'difficulty' : IDL.Float64,
    'stem' : IDL.Text,
    'topic_id' : IDL.Text,
    'choices' : IDL.Vec(IDL.Text),
  });
  return IDL.Service({
    'get_next_item' : IDL.Func(
        [IDL.Record({ 'topic_id' : IDL.Text, 'ability' : IDL.Float64 })],
        [
          IDL.Opt(
            IDL.Record({
              'id' : IDL.Text,
              'stem' : IDL.Text,
              'choices' : IDL.Vec(IDL.Text),
            })
          ),
        ],
        ['query'],
      ),
    'grade_mcq' : IDL.Func([IDL.Text, IDL.Nat32], [IDL.Bool], ['query']),
    'upsert_item' : IDL.Func([Item], [IDL.Bool], []),
  });
};
export const init = ({ IDL }) => { return []; };
