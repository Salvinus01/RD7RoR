	$(function() {
			$( "#periodo_dt_inicio_lancamento" ).datepicker({
				showOn: "button",
				buttonImage: "/images/calendario.png",
				buttonImageOnly: true,
				dateFormat: 'dd/mm/yy'
			});
		});
		
	$(function() {
		$( "#periodo_dt_aprovacao" ).datepicker({
			showOn: "button",
			buttonImage: "/images/calendario.png",
			buttonImageOnly: true,
			dateFormat: 'dd/mm/yy'
		});
	});
	
		$(function() {
			$( "#periodo_dt_fim_lancamento" ).datepicker({
				showOn: "button",
				buttonImage: "/images/calendario.png",
				buttonImageOnly: true,
				dateFormat: 'dd/mm/yy'
			});
		});

		$(function() {
			$( "#despesa_dt_documento" ).datepicker({
				showOn: "button",
				buttonImage: "/images/calendario.png",
				buttonImageOnly: true,
				dateFormat: 'dd/mm/yy'
			});
		});
		
	$(function() {
		$( "#periodo_dt_envio_financeiro" ).datepicker({
			showOn: "button",
			buttonImage: "/images/calendario.png",
			buttonImageOnly: true,
			dateFormat: 'dd/mm/yy'
		});
	});
		$(function() {
			$( "#de" ).datepicker({
				showOn: "button",
				buttonImage: "/images/calendario.png",
				buttonImageOnly: true,
				dateFormat: 'dd/mm/yy'
			});
		});	
		$(function() {
			$( "#ate" ).datepicker({
				showOn: "button",
				buttonImage: "/images/calendario.png",
				buttonImageOnly: true,
				dateFormat: 'dd/mm/yy'
			});
		});
	$(function(){
		$( "#periodo_dt_inicio_lancamento" ).mask("99/99/9999")
	});
	$(function(){
		$( "#periodo_dt_aprovacao" ).mask("99/99/9999")
	});
	$(function(){
		$( "#periodo_dt_fim_lancamento" ).mask("99/99/9999")
	});
	$(function(){
		$( "#periodo_dt_envio_financeiro" ).mask("99/99/9999")
	});
	
	$(function(){
		$( "#despesa_dt_documento" ).mask("99/99/9999")
	});
	
	$(function(){
		$( "#de" ).mask("99/99/9999")
	});
	
	$(function(){
		$( "#ate" ).mask("99/99/9999")
	});
	
function flashTimeout() {
	setTimeout(hideFlashes, 2000);				
}

function hideFlashes() {
  $('div.notice, div.warning, div.error').fadeOut(2500);
}

$(document).ready(function () {
  flashTimeout();
});

function verificaCampoDatas(){
	var dtIniLanc = document.getElementById("periodo_dt_inicio_lancamento").value;
	var dtAprov = document.getElementById("periodo_dt_aprovacao").value;
	var dtFimLanc = document.getElementById("periodo_dt_fim_lancamento").value;
	var dtEnvio = document.getElementById("periodo_dt_envio_financeiro").value;
	//data inicio lancamento
	var $dia1  = parseFloat(dtIniLanc.substring(0,2));
	var $mes1  = parseFloat(dtIniLanc.substring(3,5));
	var $ano1  = parseFloat(dtIniLanc.substring(6,10));
	var dataLanc = new Date($ano1, $mes1-1, $dia1);
	//data fim lancamento
	var $dia2  = parseFloat(dtFimLanc.substring(0,2));
	var $mes2  = parseFloat(dtFimLanc.substring(3,5));
	var $ano2  = parseFloat(dtFimLanc.substring(6,10));
	var dataFimLanc = new Date($ano2, $mes2-1, $dia2);
	//data aprovacao
	var $dia3  = parseFloat(dtAprov.substring(0,2));
	var $mes3  = parseFloat(dtAprov.substring(3,5));
	var $ano3  = parseFloat(dtAprov.substring(6,10));
	var dataAprovacao = new Date($ano3, $mes3-1, $dia3);
	//data envio financeiro
	var $dia4  = parseFloat(dtEnvio.substring(0,2));
	var $mes4  = parseFloat(dtEnvio.substring(3,5));
	var $ano4  = parseFloat(dtEnvio.substring(6,10));
	var dataEnvio = new Date($ano4, $mes4-1, $dia4);
	//hoje
	var hoje = new Date();
	if(dataFimLanc < dataLanc){
		alert("Fim do lançamento deve ocorrer depois do início do lançamento!");
		document.getElementById("periodo_dt_fim_lancamento").value = "";
		return false;
	}
	if(dataAprovacao < dataFimLanc){
		alert("Data de Limite da aprovação deve ocorrer depois do final dos lançamentos!");
		document.getElementById("periodo_dt_aprovacao").value = "";
		return false;
	}
	if(dataEnvio < dataAprovacao){
		alert("Data de envio para Financeiro deve ocorrer depois do fim das aprovações!");
		document.getElementById("periodo_dt_envio_financeiro").value = "";
		return false;
	}
	if(dataLanc < hoje){
		alert("Início do Período não pode começar antes que hoje!")
		document.getElementById("periodo_dt_inicio_lancamento").value = "";
		return false;
	}
	return true;
}

function carregaPeriodo(){
	document.getElementById("tipo_lancamento").options[0].selected = true;
	document.getElementById("tipo_despesa").options[0].selected = true;
	document.getElementById("status").options[0].selected = true;
	document.getElementById("nro_documento").value = "";
	document.getElementById("de").value = "";
	document.getElementById("ate").value = "";
	document.getElementById("page").value = "";
	document.getElementById("centro_custo").options[0].selected = true;
	document.getElementById("forma_pagamento").options[0].selected = true;
	document.forms[0].submit();
}

jQuery(document).ready(function(){
	$('#despesa_vlr_documento').priceFormat({
		prefix: 'R$ ',
		centsSeparator: ',',
		clearPrefix: true,
		thousandsSeparator: '',
		limit: 8
	});
});

jQuery(document).ready(function(){
	$('#despesa_vlr_despesa').priceFormat({
		prefix: 'R$ ',
		centsSeparator: ',',
		clearPrefix: true,
		thousandsSeparator: '',
		limit: 8
	});
});

function loteSelecionarTodos() {
			var ativar = "checked" == $("#loteSelecionarTodos").attr("checked");
			$("input[name=lote\\[\\]]").attr("checked", ativar);
		}
		
		$("#loteSelecionarTodos").unbind('change').live('change', loteSelecionarTodos);
		
function FormatarNumero(e){
				var keynum;
					
				if (window.event){ keynum = e.keyCode; }
				else if (e.which){ keynum = e.which; }
					
				if ((keynum < 48 || keynum > 57) && keynum != 8){
					if (window.event) window.event.keyCode=0; 
					return false; 
				}
				else{ return true; }
			}
			
function verificaLancamento(){
	var data = document.getElementById("despesa_dt_documento").value;
	var $dia  = parseFloat(data.substring(0,2));
	var $mes  = parseFloat(data.substring(3,5));
	var $ano  = parseFloat(data.substring(6,10));
	var hoje = new Date();
	var dtNF = new Date($ano, $mes-1, $dia);
	var vlr_doc = parseFloat(document.getElementById("despesa_vlr_documento").value.replace(",", "."));
	var vlr_reembolso = parseFloat(document.getElementById("despesa_vlr_despesa").value.replace(",", "."));
	if (dtNF > hoje){
		alert("Data de Nota Fiscal inválida. Favor inserir uma nova data.");
		document.getElementById("despesa_dt_documento").value = "";
		return false;
	} else if(vlr_reembolso > vlr_doc){
		alert("Valor de Reembolso não deve ser superior ao Valor de Nota Fiscal.");
		document.getElementById("despesa_vlr_despesa").value = "";
		return false;
	} else if(vlr_doc <= 0 || vlr_reembolso <= 0){
		alert("Digite valores de Nota Fiscal e de Reembolso maiores que 0!");
		return false
	}else
		return true;
}

function desabilitaForm(){
	input = document.getElementsByTagName("input");
	textarea = document.getElementsByTagName("textarea");
	select = document.getElementsByTagName("select");
	var i=0;
	for(i=0; i < input.length-1; i++) {
		input[i].disabled="true";
		input[i].title = "Não há período aberto."
	}
	i=0;
	for(i in textarea) {
		textarea[i].disabled="true";
		textarea[i].title = "Não há período aberto."
	}
	i=0;
	for(i in select){
		select[i].disabled="true";
		select[i].title = "Não há período aberto."
	}
}

function sublinha(){
	var ordem = document.getElementById("ordem").value;
	if(ordem == "" || ordem == "codAsc" || ordem == "codDsc")
		document.getElementById("cod").className = "ordenado";
	else
		document.getElementById("desc").className = "ordenado";
	if(ordem == "codDsc"){
		document.getElementById("img_cod").src = "/images/seta_baixo.png";
		document.getElementById("img_desc").src = "/images/seta_acima.png";
	}
	if(ordem == "descDsc"){
		document.getElementById("img_cod").src = "/images/seta_acima.png";
		document.getElementById("img_desc").src = "/images/seta_baixo.png";
	}
}


function alteraOrdem(ordem){
	var params_ordem = document.getElementById("ordem").value;
	if(ordem == "cod"){
		if(params_ordem == "" || params_ordem == "codAsc"){
			document.getElementById("ordem").value = "codDsc";
		} else {
			document.getElementById("ordem").value = "codAsc";
		}
	} else if (ordem == "desc") {
		if(params_ordem == "" || params_ordem == "descDsc"){
			document.getElementById("ordem").value = "descAsc";
		} else {
			document.getElementById("ordem").value = "descDsc";
		}
	}
	document.forms[0].submit();
}

function carregaData(){
	
	mydate = new Date();
	myday = mydate.getDay();
	mymonth = mydate.getMonth();
	myweekday= mydate.getDate();
	weekday= myweekday;

	meses = new Array(12);
	meses[0] = "Janeiro.";
	meses[1] = "Fevereiro.";
	meses[2] = "Março.";
	meses[3] = "Abril.";
	meses[4] = "Maio.";
	meses[5] = "Junho.";
	meses[6] = "Julho.";
	meses[7] = "Agosto.";
	meses[8] = "Setembro.";
	meses[9] = "Outubro.";
	meses[10] = "Novembro.";
	meses[11] = "Dezembro.";
			
	diaSem = new Array(7);
	diaSem[0] = "Domingo, ";
	diaSem[1] = "Segunda-feira, ";
	diaSem[2] = "Terça-feira, ";
	diaSem[3] = "Quarta-feira, ";
	diaSem[4] = "Quinta-feira, ";
	diaSem[5] = "Sexta-feira, ";
	diaSem[6] = "Sábado, ";
}

function motivoReprovar(despesa, motivo){
	if(confirm("Deseja reprovar a(s) despesa(s) selecionada(s)?")){
		var selectedItems = new Array();
		if (despesa)
			selectedItems = despesa;
		else{
			$("input[name='lote\\[\\]']:checked").each(function() {selectedItems.push($(this).val());});
			if (selectedItems.length == 0){
				alert("Selecione Itens para reprovação!");
				return false;
			}
		}
		if(motivo){
			$("textarea[name='motivo']").val(motivo);
		} else {
			$("textarea[name='motivo']").val("");
		}
		$("#motivo_reprovacao").dialog("open");
		document.getElementById("despesas").value = selectedItems;
	} else {
		return false;
	}
}

$(function() {
	$("#dialog:ui-dialog").dialog("destroy");
	$("#erros").dialog({
		autoOpen: false,
           height: 300,
           width: 450,
           modal: true
    });
});

function ValidaCampoDatas() {
	var dataInicial = document.getElementById("de").value;
	var dataFinal = document.getElementById("ate").value;

	if (((dataInicial == "" || dataInicial.search("_") != -1) && (dataFinal != "" || dataFinal.search("_") != -1)) || ((dataFinal == "" || dataFinal.search("_") != -1) && (dataInicial != "" || dataInicial.search("_") != -1)))
	{
		alert ("Preencher o periodo corretamente!");
		return false;
	}else{
		if (dataInicial != "" && dataFinal != "")
		{
			var erroI = "";
			var erroF = "";
			var expReg = /^([012][0-9]|3[01])\/(0[1-9]|1[012])\/([1-2][0-9]\d{2})$/;
			var $diaI  = parseFloat(dataInicial.substring(0,2));
			var $mesI  = parseFloat(dataInicial.substring(3,5));
			var $anoI  = parseFloat(dataInicial.substring(6,10));
			var $diaF  = parseFloat(dataFinal.substring(0,2));
			var $mesF  = parseFloat(dataFinal.substring(3,5));
			var $anoF  = parseFloat(dataFinal.substring(6,10));
			var dtInicial = new Date($anoI, $mesI, $diaI);
			var dtFinal = new Date($anoF, $mesF, $diaF);

			if (dtFinal < dtInicial){
				alert("Data Inicial deve ser anterior a Data Final");
				return false;
			}
			if(dataInicial.match(expReg)){
				if(($mesI==4 && $diaI>30) || ($mesI==6 && $diaI>30) || ($mesI==9 && $diaI>30) || ($mesI==11 && $diaI>30)){
					erroI = "Data incorreta! O mês "+$mesI+" contém 30 dias.";
				}else{
					if($anoI%4!=0 && $mesI==2 && $diaI>28){
						erroI = "Data incorreta!! O mês "+$mesI+" contém 28 dias.";
					}else{
						if($anoI%4==0 && $mesI==2 && $diaI>29){
							erroI = "Data incorreta!! O mês "+$mesI+" contém 29 dias.";
						}
					}
				}

			}else{
				if ($diaI<1 || $diaI>31) {
					erroI = "Dia "+$diaI+" inválido.";
				}else{
					if ($mesI<1 || $mesI>12) {
						erroI = "Mês "+$mesI+" inválido.";
					}else{
						erroI = "Data Inválida.";
					}
				}
			}

			if(dataFinal.match(expReg)){
				if(($mesF==4 && $diaF>30) || ($mesF==6 && $diaF>30) || ($mesF==9 && $diaF>30) || ($mesF==11 && $diaF>30)){
					erroF = "Data incorreta! O mês "+$mesF+" contém 30 dias.";
				}else{
					if($anoF%4!=0 && $mesF==2 && $diaF>28){
						erroF = "Data incorreta!! O mês "+$mesF+" contém 28 dias.";
					}else{
						if($anoF%4==0 && $mesF==2 && $diaF>29){
							erroF = "Data incorreta!! O mês "+$mesF+" contém 29 dias.";
						}
					}
				}

			}else{
				if ($diaF<1 || $diaF>31) {
					erroF = "Dia "+$diaF+" inválido.";
				}else{
					if ($mesF<1 || $mesF>12) {
						erroF = "Mês "+$mesF+" inválido.";
					}else{
						erroF = "Data Inválida.";
					}
				}
			}

			if(erroI){
				alert(erroI);
				document.getElementById("de").value = "";
				return false;
			}
			if(erroF){
				alert(erroF);
				document.getElementById("ate").value = "";
				return false;
			}

			return true;
		}
	}
}

function verificaCampo(){
	if(document.getElementById("email").value == ""){
		alert("Digite seu email!");
		return false;
	} else
		return true;
}

