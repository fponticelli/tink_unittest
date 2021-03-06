package tink.unit;

import tink.testrunner.Assertion;
import haxe.macro.Expr;
import haxe.macro.Context;

#if macro
using tink.MacroApi;
#end

class Assert {
	static var printer = new haxe.macro.Printer();
	
	#if macro
	static var posInfos = Context.getType('haxe.PosInfos');
	#end
	
	public static macro function assert(expr:ExprOf<Bool>, ?description:ExprOf<String>, ?pos:ExprOf<haxe.PosInfos>):ExprOf<Assertion> {
		var pre = macro {};
		var assertion = expr;
		
		switch description {
			case macro null:
			default:
				if(Context.unify(Context.typeof(description), posInfos)) {
					pos = description;
					description = macro null;
				}
		}
				
		switch description {
			case macro null:
				description = macro $v{expr.toString()};
				
				// TODO: we can actually do a recursive breakdown: e.g. `a == 1 && b == 2`
				switch expr.expr {
					case EBinop(op, e1, e2):
						
						var operator = printer.printBinop(op);
						var operation = EBinop(op, macro lh, macro rh).at(expr.pos);
						
						pre = macro {
							// store the values to avoid evaluating the expressions twice
							var lh = $e1; 
							var rh = $e2;
						}
						assertion = operation;
						description = macro $description + ' (' + tink.unit.Assert.stringify(lh) + ' ' + $v{operator} + ' ' + tink.unit.Assert.stringify(rh) + ')';
						
					default:
				}	
			default:
		}
		
		var args = [assertion, description];
		switch pos {
			case macro null: // skip
			case v: args.push(v);
		}
		return pre.concat(macro @:pos(expr.pos) new tink.testrunner.Assertion($a{args}));
	}
	
	#if !macro
	public static function stringify(v:Dynamic) {
		return 
			if(Std.is(v, String) || Std.is(v, Float) || Std.is(v, Bool)) haxe.Json.stringify(v);
			else Std.string(v);
	}
	#end
}