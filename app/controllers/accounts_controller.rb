class AccountsController < ApplicationController
    before_action :require_login
    before_action :require_admin, only: [:show, :update, :destroy]
      
    # GET 
    def index
      @accounts = Account.all
    end
     
    # DELETE
    def destroy
    end
   
  end
  