/*!
 * j7Spec v0.2.0
 *
 * Componente JavaScript responsável por executar as especificações do 7Spec em uma tela (página html).
 * É baseado nos objetos JSON retornados pelo serviço SevenSpecData. 
 */
function j7Spec(options){
	this.options = options || {};
	this.informacoesDeDebug = null;
	
	this.aplicarEspecificacao = function(especificacao, form) {
		this.traduzir = true;
		this.validar = true;
		this.executar(especificacao, form);
	};

	this.aplicarRegrasDeValidacao = function(especificacao, form) {
		this.traduzir = false;
		this.validar = true;
		this.executar(especificacao, form);
	};
	
	this.aplicarTraducao = function(especificacao) {
		this.traduzir = true;
		this.validar = false;
		this.executar(especificacao, undefined);
	};	

	this.executar = function(especificacao, form) {
		this.debug = this.options.debug || false;
		this.inputSelector = this.options.inputSelector || this.defaultInputSelector;
		
		for (var i = 0; i < especificacao.entidades.length; i++) {
			var e = especificacao.entidades[i];
			var entidade_nome_auxiliar = ""
			
			for (var x = 0; x < e.nome.length; x++){
				var expLetraMaiuscula = new RegExp('[A-Z]');
				var expMatch = e.nome[x].match(expLetraMaiuscula);
				
				if (expMatch == null){
					expMatch = 0;
				}
				
				if (e.nome[x] == expMatch){
					entidade_nome_auxiliar = entidade_nome_auxiliar + e.nome[x];
					entidade_nome_auxiliar = entidade_nome_auxiliar.replace(e.nome[x], "_" + e.nome[x].toLowerCase());					
				}else{
					entidade_nome_auxiliar = entidade_nome_auxiliar + e.nome[x];
				}
			}
			
			if (entidade_nome_auxiliar[0] == "_"){
				entidade_nome_auxiliar = entidade_nome_auxiliar.substring(1, entidade_nome_auxiliar.length);
			}
			e.nome = entidade_nome_auxiliar;
			
			for (var j = 0; j < e.campos.length; j++) {
				var c = e.campos[j];
				var input = this.inputSelector(e.nome, c);
				
				if (input.size() < 1) {
					if (this.debug) {
						this.informacaoDeDebug($.validator.format("nao encontrou input referente ao campo {0} da entidade {1}", c.nome, e.nome));		
					}
					continue;
				}
				if (this.traduzir && c.label) {
					var label_acessor = e.nome + "_" + c.nome;
					var label = this.labelCorrespondente(label_acessor);

					if (label.size() > 0) {
						label.text(c.label);
						if (this.debug) {
							label.css("background-color", "LimeGreen");
						}
					} else {						
						if (this.debug) {
							this.informacaoDeDebug($.validator.format("nao encontrou label referente ao campo {0} da entidade {1}", c.nome, e.nome));		
						}
					}
				}
				if (this.validar) {
					for (var k = 0; k < c.regras.length; k++) {
						c.regras[k].nome = "regra_" + e.nome + "_" + c.nome + "_" + k;
						var nomeDoCampoNaMensagem = label ? label.text().replace(":","").replace("*","") : c.nome;						
						if (c.regras[k].regex) {
							this.aplicarRegra(input, nomeDoCampoNaMensagem, c.regras[k]);						
						} else if (c.regras[k].funcao) {
							var f = c.regras[k].funcao;
							try {
								eval(c.regras[k].funcao);
								c.regras[k].funcaoEncontrada = true;
								this.aplicarRegra(input, nomeDoCampoNaMensagem, c.regras[k]);
							} catch(e) {
								if (this.debug) {
									this.informacaoDeDebug($.validator.format("nao encontrou função {0}. Regra não será aplicada", c.regras[k].funcao));
								}
							}
						}
					}
					
					if (this.debug) {
						this.saidaDeDebugDoInput(input, c.regras);				
					}
				}
			}				
		}			
		
		if (this.validar) {
			if (this.options.divDialog){
				controle = "#"+this.options.divDialog;
				$(controle).append("<ul id='messageBox'></ul>");
				form.validate({
					errorClass: "warning",
					onkeyup: false,
					onblur: false,
					onfocusout: false,
					errorLabelContainer: "#messageBox",
					wrapper: "li",
					invalidHandler: function(form, validator) {
						$("#erros").dialog("open");
					}
				});
			}
			else if (this.options.divNoDialog){
				controle = "#"+this.options.divNoDialog;
				$(controle).append("<ul id='messageBox'></ul>");
				$(controle).hide();
				form.validate({
					errorClass: "warning",
					onkeyup: false,
					onfocusout: false,
					errorLabelContainer: "#messageBox",
					wrapper: "li",
					invalidHandler: function(form, validator) {
						$(controle).fadeIn(600);
					}
				});
			}
			else{
				form.validate({
					errorClass: "warning",
					onkeyup: false,
					onblur: false,
				});
			}
		}

		if (this.debug && this.informacoesDeDebug) {
			alert("j7Spec: saida de debug\n\n" + this.informacoesDeDebug);
		}
	};
	
	this.aplicarRegra = function(input, nomeDoCampoNaMensagem, regra) {	
		input.addClass(regra.nome);
		
		$.validator.addMethod(regra.nome, function(value, element) {		
				if (regra.regex) {
					return value.match(regra.regex);
				} else if (regra.funcao) {
					return eval(regra.funcao + "(value);");
				}				
			}, $.validator.format(regra.mensagem, nomeDoCampoNaMensagem)
		);
	};

	this.defaultInputSelector = function(entidade, campo) {
		return $("#" + entidade + "_" + campo.nome);
	};
	
	this.labelCorrespondente = function(idInput) {
		return $("label[for=" + idInput + "]");
	};
	
	this.informacaoDeDebug = function(info) {
		if (!this.informacoesDeDebug) {
			this.informacoesDeDebug = info;
		}	else {
			this.informacoesDeDebug += "\n\n" + info;
		}
	};
	
	this.saidaDeDebugDoInput = function(input, regras) {
		var saida = [];
		for (var i=0; i < regras.length; i++) {
			if (regras[i].regex) {
				saida.push("regex " + regras[i].regex);				
			} else if (regras[i].funcao && regras[i].funcaoEncontrada) {
				saida.push("função " + regras[i].funcao);
			}
		}
		
		input.css("color", "red");						
		input.css("font-weight", "bold");												
		input.val(saida.length + " regra(s)");
		
		input.click(function() {
			alert(saida.join("\n\n"));
		});	
	};
}

function validaCPF(cpf){
	var numeros, digitos, soma, i, resultado, digitos_iguais;
	digitos_iguais = 1;
	cpf = cpf.replace(".", "").replace(".", "").replace("-", "")
	
	if (cpf.length != 11){
		return false;
	}
	
	for (i = 0; i < cpf.length - 1; i++){
		if (cpf.charAt(i) != cpf.charAt(i + 1)){
			digitos_iguais = 0;
			break;
		}
	}
	
	if (!digitos_iguais){
		numeros = cpf.substring(0,9);
		digitos = cpf.substring(9);
		soma = 0;
		
		for (i = 10; i > 1; i--){
			soma += numeros.charAt(10 - i) * i;
		}
		
		resultado = soma % 11 < 2 ? 0 : 11 - soma % 11;
		if (resultado != digitos.charAt(0)){
			return false;
		}
		
		numeros = cpf.substring(0,10);
		soma = 0;
		
		for (i = 11; i > 1; i--){
			soma += numeros.charAt(11 - i) * i;
		}
		
		resultado = soma % 11 < 2 ? 0 : 11 - soma % 11;
		if (resultado != digitos.charAt(1)){
			return false;
		}
		return true;
	}else{
		return false;
	}
}
	
function validaCNPJ(cnpj){
	var numeros, digitos, soma, i, resultado, pos, tamanho, digitos_iguais;
	digitos_iguais = 1;
	cnpj = cnpj.replace(".", "").replace(".", "").replace("-", "").replace("/", "")
			
	if (cnpj.length != 14){
		return false;
	}
	
	for (i = 0; i < cnpj.length - 1; i++){
		if (cnpj.charAt(i) != cnpj.charAt(i + 1)){
			  digitos_iguais = 0;
			  break;
		}
	}
	
	if (!digitos_iguais){
		tamanho = cnpj.length - 2
		numeros = cnpj.substring(0,tamanho);
		digitos = cnpj.substring(tamanho);
		soma = 0;
		pos = tamanho - 7;
		
		for (i = tamanho; i >= 1; i--){
			soma += numeros.charAt(tamanho - i) * pos--;
			if (pos < 2){
				pos = 9;
			}
		}
		
		resultado = soma % 11 < 2 ? 0 : 11 - soma % 11;
		if (resultado != digitos.charAt(0)){
			return false;
		}
		
		tamanho = tamanho + 1;
		numeros = cnpj.substring(0,tamanho);
		soma = 0;
		pos = tamanho - 7;
		
		for (i = tamanho; i >= 1; i--){
			soma += numeros.charAt(tamanho - i) * pos--;
			if (pos < 2){
				pos = 9;
			}
		}
		
		resultado = soma % 11 < 2 ? 0 : 11 - soma % 11;
		if (resultado != digitos.charAt(1)){
			return false;
		}
		return true;
		
	}else{
		return false;
	}
}