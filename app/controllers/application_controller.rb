class ApplicationController < ActionController::Base
include SevenControlAuthClient::Filtro
	protect_from_forgery
	has_mobile_fu # Detect the device type
	before_filter :autenticar, :carregar_usuario, :carregar_funcionalidades, :set_request_format

  def set_request_format
    request.format = :mobile if is_mobile_device?
  end
  
  def carregar_funcionalidades 
	begin
		  if !request.cookies["_SevenControlAuth_session"].nil?
		   cookie = "_SevenControlAuth_session=" + request.cookies[APP_CONFIG['cookie_name']] 
		   resposta = SevenControlAuthClient::Requisicoes.requisicao_get("/current_funcionalidades/" + APP_CONFIG['cod_produto'].to_s + ".json",cookie)
		   respostaJson = ActiveSupport::JSON.decode resposta.body
   
		   @funcionalidades = respostaJson
		   
		   if @funcionalidades[0].nil? 
				return
		   end
		   
			@acesso = @funcionalidades[0]['CodFuncionalidade'].upcase
			
		  end

		  rescue
			redirect_to root_url
		 end		  
	end
  
  def carregar_usuario
		if !@usuario7control.nil?
			@usuario_logado =  Usuario.find(:first, :conditions => ['login_7Control = ?', @usuario7control['DscLogin'] ] )
		end
	end
	
	def verifica_administrador
		if @acesso != "RD7WEB003"
			flash[:error] = "Você não possui permissão para acessar esta página. Favor contactar o Administrador."
			redirect_to "/home/index"
		end
	end

end
