export interface Flags {}

export interface Ports {}

export interface Options {
    node: HTMLElement;
    flags?: Flags;
}

export interface Main {
    init(options?: Options): { ports: Ports };
}

declare module Elm {
    export namespace Elm { const Main: Main; }
}

export default Elm;
