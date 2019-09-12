
class MyParser extends Parser;
{
	java.util.HashMap<String, Variables> mapaVar;
	java.util.HashMap<String, Variables> mapaTipo;

	java.util.ArrayList<Expression> expList = new java.util.ArrayList<Expression>();
	java.util.ArrayList<CmdLoop> loopList = new java.util.ArrayList<CmdLoop>();
	Expression expression;
	AbstractOperand num;
	AbstractOperand parent;
	BinaryOperand sumOrSubt;
	BinaryOperand multOrDiv;
	Variables variables;
	char op;
	CmdLoop loop;
	String loopName;
	CmdAtribuicao cmdAtribuicao;

	Program p;

	public void setProgram(String name){
      p = new Program(name);
    }

    public Variables checkMapaVar(String varName) {
    	if( (loopName != null) && (mapaVar.get(loopName+varName) != null) )
    		return mapaVar.get(loopName+varName);
    	else if( mapaVar.get(varName) != null )
    		return mapaVar.get(varName);
    	return null;
    }
  
    public Program getProgram(){
       return p;
    }
}

prog    :   {mapaVar = new java.util.HashMap<String, Variables>();}
			"programa" declara bloco
		;

declara :   "declare" 
			/*T_Id {
					
					mapaTipo.put( LT(0).getText(), new Variables(LT(0).getText()) );
				 }*/
			T_Id {mapaVar.put( LT(0).getText(), new Variables(LT(0).getText()) ); }
			(T_virg T_Id {mapaVar.put(LT(0).getText(), new Variables(LT(0).getText()) ); } )*
			T_pontof
			{
		      p.setVariaveis(mapaVar.values());
			  System.out.println("Variable list assembled...");
		    }
        ;

bloco	:	( cmd )+ "fimprog"
		;

cmd     : 	cmdLeia 	T_pontof
		|	cmdEscr		T_pontof
		|	cmdAttr		T_pontof {System.out.println("Fim Bloco atribuicao");}
		|	cmdIgnore   T_pontof
		|   cmdIfElse	T_pontof
		|	cmdLoop     T_pontof
		;

cmdIgnore : T_comt ( T_Id | T_num | T_soma | T_subt | T_mult | T_divi | T_comp
		  | T_virg | T_ap | T_fp | T_texto | T_attr | "leia" | "escreva" | "se" | "entao" )* // seguido de qualquer coisa
		  ;

cmdLoop	:	"repita" T_ap
						T_Id {
								loop = new CmdLoop();
								if( mapaVar.get(LT(0).getText()) == null )
								{
									loopName = loop.getLoop_name();
									loop.setIterator(new Variables(loop.getLoop_name()+LT(0).getText()));
									mapaVar.put( loop.getIterator().getName(), loop.getIterator() );
								}
								else
									loop.setIterator( mapaVar.get(LT(0).getText()) );
							 }
						T_attr T_num {
										loop.getIterator().setValue(LT(0).getText());
										loop.getIterator().setType(DataTypes.TYPE_DOUBLE);
									 } T_pontof

						(T_num {loop.setWhile_var1(new Variables(Variables.NUMBER, LT(0).getText(), DataTypes.TYPE_DOUBLE) );}
						| T_Id {
									if(checkMapaVar(LT(0).getText()) != null)
										loop.setWhile_var1(checkMapaVar(LT(0).getText()));
									else
										throw new RuntimeException("ERROR ID " + LT(0).getText() + " not declared");
							   })

						T_comp {loop.setComparador(LT(0).getText());}
						(T_num {loop.setWhile_var2(new Variables(Variables.NUMBER, LT(0).getText(), DataTypes.TYPE_DOUBLE) );}
						| T_Id {
									if(checkMapaVar(LT(0).getText()) != null)
										loop.setWhile_var2( checkMapaVar(LT(0).getText()) );
									else
										throw new RuntimeException("ERROR ID " + LT(0).getText() + " not declared");
							   }) T_pontof

						(T_subt | T_soma | T_mult | T_divi) {loop.setIncrementOp(LT(0).getText());}
						(T_num {loop.setIncrement(new Variables(Variables.NUMBER, LT(0).getText(), DataTypes.TYPE_DOUBLE) );}
						| T_Id {
									if(checkMapaVar(LT(0).getText()) != null)
										loop.setIncrement( checkMapaVar(LT(0).getText()) );
									else
										throw new RuntimeException("ERROR ID " + LT(0).getText() + " not declared");
							   })
					T_fp 
					T_ac ( ( cmdLeia | cmdEscr | cmdAttr | cmdIgnore ) T_pontof )+ {loop.addCommand(p.popCommand());} T_fc

			{
				p.addCommand(loop);
				loopName = null;
			}
		;

cmdIfElse:  "se" T_ap T_num T_fp T_ac ( (cmdLeia | cmdEscr | cmdAttr | cmdIgnore) T_pontof )+ T_fc 
			("entao" T_ac ( (cmdLeia | cmdEscr | cmdAttr | cmdIgnore) T_pontof )+ T_fc )?
		;

cmdLeia	:	"leia" {System.out.println("Bloco leia");} T_ap
			T_Id {
					if( checkMapaVar(LT(0).getText()) == null )
						throw new RuntimeException("ERROR ID " + LT(0).getText() + " not declared");

					p.addCommand(new CmdLeitura(checkMapaVar(LT(0).getText()).getName()));
				 }

			T_fp
		;

cmdEscr	: 	"escreva" {System.out.println("Bloco escreva");}
				
			T_ap ( T_texto { p.addCommand(new CmdEscrita(LT(0).getText())); }
			| T_Id
				{
					if( checkMapaVar(LT(0).getText()) == null )
						throw new RuntimeException("ERROR ID " + LT(0).getText() + " not declared");
					p.addCommand(new CmdEscrita(checkMapaVar(LT(0).getText()).getName()));
				} )
			T_fp
		;

cmdAttr	: 	T_Id { 
					if( checkMapaVar(LT(0).getText()) == null )
						throw new RuntimeException("ERROR ID " + LT(0).getText() + " not declared");
					cmdAtribuicao = new CmdAtribuicao(checkMapaVar(LT(0).getText()));
					p.addCommand(cmdAtribuicao);
				 }
			T_attr  {
						System.out.println("Bloco atribuicao");
						expList = new java.util.ArrayList<Expression>();
						cmdAtribuicao.setCommand(expList);
					} expr
		;

expr	: {expression = new Expression();} 
           expr_c
          {
            if (expression.getRoot() == null) expression.setRoot(num);
            expList.add( expression );
            expression.eval();
            System.out.println(expression);
            System.out.println(expression.getRoot().toXml());
            expression = null;
          }
		;

//        termo ((T_soma  | T_subt) termo)*
expr_c  : termo
          ((T_soma  | T_subt){
          						op = LT(0).getText().charAt(0);
                                sumOrSubt = new BinaryOperand(op);
                                sumOrSubt.setLeft(num);
                                System.out.println("fim set left");
                             }
          termo {
                   if(expression.getRoot() == null)
                   {
						System.out.println("root null");
						sumOrSubt.setRight(num);
						expression.setRoot(sumOrSubt);
						parent = sumOrSubt;
                   }
                   else
                   {
						System.out.println("root not null");
						sumOrSubt = new BinaryOperand(op);
						sumOrSubt.setRight(num);
						BinaryOperand pai = (BinaryOperand)parent;
						sumOrSubt.setLeft(pai.getRight());
						pai.setRight(sumOrSubt);
                   }
                }
          )*
		;

		// fator (( T_mult | T_divi ) fator )*
termo 	:	{System.out.println("termo");} fator (( T_mult | T_divi ) fator )* {System.out.println("fim termo");}
		;

		// T_Id | T_num | T_ap expr T_fp
fator 	: 	{System.out.println("inicio fator");}T_Id { 
					if( checkMapaVar(LT(0).getText()) == null )
					{
						throw new RuntimeException("ERROR ID " + LT(0).getText() + " not declared");
					}
					else
					{
						num = new UnaryOperand( Float.parseFloat( checkMapaVar(LT(0).getText()).getValue() ) );
						System.out.println("Unary operand (var): " + num.getValue());
					}
				 }

		| T_num {
					System.out.println("setando um fator");
					num = new UnaryOperand(Float.parseFloat(LT(0).getText()));
					System.out.println("Unary operand (num): " + num.getValue());
                }

		| T_ap expr T_fp

		;




class MyLexer extends Lexer;
options{
	caseSensitive = true;
	k=2;
}

T_Id 		:	( 'a'..'z' | 'A'..'Z') ('a'..'z' | 'A'..'Z' | '0'..'9')*
			;

T_num 		:   ('0'..'9')+ (('.') ('0'..'9')+)?
			;

T_soma		:	'+'
			;

T_subt		:	'-'
			;

T_mult		:	'*'
			;

T_divi		:	'/'
			;

T_virg		:	','
			;

T_pontof	:	';'
			;

T_ap		:	'('
			;

T_fp		:	')'
			;

T_ac		:	'{'
			;

T_fc		:	'}'
			;

T_texto		:	'"' ( ' ' | '!' | '#'..'Z' | '_'..'~' )+ '"'
			;

T_attr		:	'='
			;

T_blank		:	( ' ' | '\n' {newline();} | '\r' | '\t' ) {_ttype=Token.SKIP;}
			;

T_comt		:	"//"
			;

T_comp		: '<' | "<=" | '>' | ">=" | "!=" | "?="
			;
