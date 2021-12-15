class AdminController < ApplicationController
	
	skip_before_filter :autenticar, :only => [:login,:fazer_login,:recover,:recuperar_senha, :alterar_senha_token]
	skip_before_filter :verificar_funcionalidade
	skip_before_filter :carregar_funcionalidades
	skip_before_filter :verificar_administrador
	
	require "net/http"
	layout :escolher_layout
	
	def login
	
	end
	
	def edit
		
	end

	
	def fazer_login
		@usuario = {:user => {:DscLogin => params[:DscLogin], :password => params[:password] }}
		
		begin
			resposta = SevenControlAuthClient::Requisicoes.requisicao_post("/login_direto/#{APP_CONFIG['cod_produto']}.json", @usuario.to_json)
			respostaJson = ActiveSupport::JSON.decode resposta.body
			if respostaJson['success'] == true
				set_cookie = [] 
				set_cookie = resposta['Set-Cookie'].split('=')
				nome = set_cookie[0]
				valores = set_cookie[1].split(';')
				valor = valores[0]
				cookies[nome] = valor
				if respostaJson['primeiro_login'] == true
					respond_to do |format|
						format.html { redirect_to alterar_senha_url }
					end	
				else
					respond_to do |format|
						format.html { redirect_to root_url }
					end				
				end
			else
				redirect_to :back
				flash[:error] = "Usuário e/ou senha inválidos!"
			end
		rescue
			redirect_to :back
			flash[:error] = "Ocorreu um erro inesperado. Tente novamente mais tarde."
		end
	end
	
	def alterar_senha
		@alterarUsuarioPrimeiroAcesso = 1
		@usuario = {:user => 
					{:current_password => params[:current_password], 
					:password => params[:password], 
					:password_confirmation => params[:password_confirmation] }}
		cookie = "_SevenControlAuth_session=" + request.cookies[APP_CONFIG['cookie_name'].to_s] 
		resposta = SevenControlAuthClient::Requisicoes.requisicao_post("/passwords_change.json", @usuario.to_json, cookie)
		respostaJson = ActiveSupport::JSON.decode resposta.body

		if respostaJson['resposta'] == true && respostaJson['cookie_delete'] == true
			cookie.delete(APP_CONFIG['cookie_name'])
			flash[:notice] = "Senha alterada com sucesso!"
			@alterarUsuarioPrimeiroAcesso = 0
			redirect_to root_url
		else
			msg = ""	
			@passwords = respostaJson['errors']
			@passwords.each do |password_erro|
				if password_erro == "Current password can't be blank"
					password_erro = "Campo Senha Atual não pode ficar em branco! "
				end
				if password_erro == "Password can't be blank"
					password_erro = "Campo Nova Senha não pode ficar em branco! "
				end
				if password_erro == "Current password is invalid"
					password_erro = "A senha atual informada é inválida! "
				end
				if password_erro == "Password doesn't match confirmation"
					password_erro = "A confirmação de senha não corresponde a nova senha! "
				end
				msg += password_erro + "\n"
			end		
			
			flash[:error] = msg
			redirect_to :back
		end
	end
	
	
	def logout
		$usuario = nil
		@usuario7Control = nil
		cookies.delete APP_CONFIG['cookie_name']
		redirect_to root_url
	end
	
	def recover
	end
	
	def recuperar_senha
		@usuario = {:user => 
										{:email => params[:email] }}
		resposta = SevenControlAuthClient::Requisicoes.requisicao_post("/passwords_recuperar.json", @usuario.to_json)
		respostaJson = ActiveSupport::JSON.decode resposta.body
		
		if respostaJson['resposta'] == true
			redirect_to login_path
			flash[:notice] = "Um e-mail foi enviado para recuperar sua senha."
			
		else
			redirect_to recover_url
			
			flash[:error] = "Não foi possível enviar o e-mail para este endereço."
			
		end
	end
	
	def alterar_senha_token

		@usuario = {:user => 
					{:reset_password_token => params[:reset_password_token], 
					:password => params[:password],
					:password_confirmation => params[:password]}}
		
		resposta = SevenControlAuthClient::Requisicoes.requisicao_post("/passwords_update_token.json", @usuario.to_json)
		respostaJson = ActiveSupport::JSON.decode resposta.body
		
		if respostaJson['resposta'] == true
			redirect_to root_url
		else
			flash.now[:error] = respostaJson['errors']
			redirect :back
		end
	end
	
	private

	 def escolher_layout
		if !['logout', 'alterar_senha', 'recuperar_senha', 'fazer_login', 'login', 'edit', 'edit_with_token', 'recover'].include? action_name
			'application'
		else	
			'login'
		end
	end
end