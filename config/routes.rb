RD7::Application.routes.draw do
  
  root :to => 'home#index'
  
  get "home/index"
  
  resources :home do
	collection do
		
	end
  end

  resources :tipo_lancamentos do
	collection do
		post :ativar
		post :inativar
	end
  end

  resources :forma_pagamentos do
	collection do
		post :ativar
		post :inativar
	end
  end
   resources :periodos do
		collection do			
			post :ativar
			post :inativar
		end
   end
   
   resources :centro_custos do
	collection do
		post :ativar
		post :inativar
	end
   end
   
   resources :tipo_despesas do
	collection do
		post :ativar
		post :inativar
	end
   end
	
	resources :despesas do
		collection do
			get :enviar_aprovacao
			get :aprovacao
			get :aprovacao_detalhe
			post :aprovar
			post :reprovar
		end
	end
	match 'admin/login' => 'admin#login', :as => 'login'
	match 'admin/recover' => 'admin#recover', :as => 'recover'
	match 'admin/fazer_login' => 'admin#fazer_login', :as => 'fazer_login', :method => :post
	match 'admin/alterar_senha' => 'admin#alterar_senha', :as => 'executa_alterar_senha', :method => :post
	match 'admin/recuperar_senha' => 'admin#recuperar_senha', :as => 'recuperar_senha', :method => :post
	match 'admin/logout' => 'admin#logout', :as => 'logout', :method => :delete
	match 'admin/edit' => 'admin#edit', :as => 'alterar_senha'

end
