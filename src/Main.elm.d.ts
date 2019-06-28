interface CommandPort<T> {
    subscribe(handler: (payload: T) => void): void;
}

export interface Flags {
    token: string | null;
}

export interface Ports {
    token_: CommandPort<string>;
}

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
