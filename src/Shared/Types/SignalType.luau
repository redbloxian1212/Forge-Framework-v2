--!strict
type SignalType<T...> = {
	Connect: (self: any, callback: (T...) -> ()) -> any,
	Once: (self: any, callback: (T...) -> ()) -> any,
	Wait: (self: any) -> T...,
	Fire: (self: any, T...) -> (),
	DisconnectAll: (self: any) -> (),
}

export type Signal<T...> = SignalType<T...>

return {}
