package tink.unit;

import tink.testrunner.*;
import tink.streams.Stream;
import haxe.macro.Expr;

using tink.CoreApi;

#if pure 
private class Impl extends SignalStream<Assertion, Error> {
	var trigger:SignalTrigger<Yield<Assertion, Error>>;
	public function new() {
		trigger = Signal.trigger();
		super(trigger.asSignal());
	}
	public inline function yield(data)
		trigger.trigger(data);
}
#else
private typedef Impl = tink.streams.Accumulator<Assertion>;
#end



abstract AssertionBuffer(Impl) to Assertions {
	
	public macro function assert(ethis:Expr, result:ExprOf<Bool>, ?description:ExprOf<String>, ?pos:ExprOf<haxe.PosInfos>):ExprOf<Assertion> {
		var args = [result, description];
		switch pos {
			case macro null:
			default: args.push(pos);
		}
		return macro $ethis.emit(tink.unit.Assert.assert($a{args}));
	}
		
	#if !macro
	public inline function new()
		this = new Impl();
		
	public inline function emit(assertion:Assertion)
		this.yield(Data(assertion));
		
	public inline function fail(?code:Int, reason:FailingReason, ?pos:haxe.PosInfos) {
		if(code == null) code = reason.code;
		this.yield(Fail(new Error(code, reason.message, pos)));
		return this;
	}
	
	public inline function done():Assertions {
		this.yield(End);
		return this;
	}
	
	public function handle<T>(outcome:Outcome<T, Error>)
		switch outcome {
			case Success(_): done();
			case Failure(e): fail(e.code, e);
		}
	#end
}

@:forward
abstract FailingReason(Error) from Error to Error {
	@:from
	public static inline function ofString(e:String):FailingReason
		return new Error(e);
}