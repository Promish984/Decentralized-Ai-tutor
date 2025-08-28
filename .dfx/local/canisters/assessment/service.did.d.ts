import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';
import type { IDL } from '@dfinity/candid';

export interface Item {
  'id' : string,
  'key' : number,
  'difficulty' : number,
  'stem' : string,
  'topic_id' : string,
  'choices' : Array<string>,
}
export interface _SERVICE {
  'get_next_item' : ActorMethod<
    [{ 'topic_id' : string, 'ability' : number }],
    [] | [{ 'id' : string, 'stem' : string, 'choices' : Array<string> }]
  >,
  'grade_mcq' : ActorMethod<[string, number], boolean>,
  'upsert_item' : ActorMethod<[Item], boolean>,
}
export declare const idlFactory: IDL.InterfaceFactory;
export declare const init: ({ IDL }: { IDL: IDL }) => IDL.Type[];
