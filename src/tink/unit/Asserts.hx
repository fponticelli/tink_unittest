package tink.unit;

import tink.streams.Stream;
import tink.streams.Accumulator;
import haxe.PosInfos;

using tink.CoreApi;

@:forward
abstract Asserts(Stream<Assertion>) from Stream<Assertion> to Stream<Assertion> {
	@:from
	public static inline function ofOutcome(o:Outcome<Noise, Error>):Asserts {
		var buffer = new AssertBuffer();
		buffer.add(o);
		return buffer.complete();
	}
	
	@:from
	public static inline function ofSurprise(p:Surprise<Noise, Error>):Asserts {
		var buffer = new AssertBuffer();
		p.handle(function(o) {
			buffer.add(o);
			buffer.complete();
		});
		return buffer;
	}
	
	@:from
	public static inline function flatten(p:Promise<Asserts>):Asserts {
		return Stream.later((p:Promise<Stream<Assertion>>));
	}
}

@:forward
abstract AssertBuffer(Accumulator<Assertion>) to Stream<Assertion> to Asserts {
	
	public inline function new()
		this = new Accumulator();
		
	public inline function equals<T>(expected:T, actual:T, ?errmsg:String, ?pos:PosInfos)
		add(Assertion.equals(expected, actual, errmsg, pos));
	
	public inline function notEquals<T>(expected:T, actual:T, ?errmsg:String, ?pos:PosInfos)
		add(Assertion.notEquals(expected, actual, errmsg, pos));
	
	public inline function isNull<T>(actual:T, ?errmsg:String, ?pos:PosInfos)
		add(Assertion.isNull(actual, errmsg, pos));
	
	public inline function notNull<T>(actual:T, ?errmsg:String, ?pos:PosInfos)
		add(Assertion.notNull(actual, errmsg, pos));
	
	public inline function isTrue(actual:Bool, ?errmsg:String, ?pos:PosInfos)
		add(Assertion.isTrue(actual, errmsg, pos));
	
	public inline function isFalse(actual:Bool, ?errmsg:String, ?pos:PosInfos)
		add(Assertion.isFalse(actual, errmsg, pos));
	
	#if deep_equal
	public inline function deepEquals(expected:Dynamic, actual:Dynamic, ?pos:PosInfos)
		add(Assertion.deepEquals(expected, actual, errmsg, pos));
	#end
	
	public inline function add(assertion:Assertion) {
		this.yield(Data(assertion));
	}
	
	public inline function complete():Stream<Assertion> {
		this.yield(End);
		return this;
	}
}