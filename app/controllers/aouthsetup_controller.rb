class AouthsetupController < ApplicationController
  
require 'http'
CTX = OpenSSL::SSL::SSLContext.new
CTX.verify_mode = OpenSSL::SSL::VERIFY_NONE
  
  #トップページ（入力画面）
  def setup
  end
  
  
  #入力値の受取り画面
  def getcode
    
    #Veiwから値を受取る
    @@key = 	params[:email].presence
    @@client =	params[:clientId].presence
    #@@client = 'b64e0af10b89dfb7ed58310cae5598e8d913a274642ff8ec56e3a9791a39eb87'
    @@secret =	params[:clientSecret].presence
    #@@secret = 'dfc26c554e7d988abcde977de7892b6005dee2ecd18b984b7c703ddd233edb15'
    @@callbackuri = 'https://sample-yumikotsunai.c9users.io/aouthsetup/callback'
    
    #connectのoauth認証のためのURLにアクセスする  (A)リソースオーナーにAuthorization Request送信
    req = 'https://connect.lockstate.jp/oauth/'+'authorize?'+'client_id='+@@client+'&response_type=code&redirect_uri='+@@callbackuri
    #req = 'https://connect.lockstate.jp/oauth/authorize?client_id=cef946186caabbc4d8b691b6baa7b6e774bfbfe2cafa8f85709aa51cd89be0a1&response_type=code&redirect_uri=urn:ietf:wg:oauth:2.0:oob'
    redirect_to req
    
  end
  
  
  #認証コードの受取りとトークンの発行
  def callback
    
    #(B)リソースオーナーからAuthorization Grant受取り
    code = params[:code].presence
    
    
    #(C)認可サーバーにAuthorization Grant送信
    postform = {'code' => code \
    ,'client_id' => @@client \
    ,'client_secret' => @@secret \
    ,'redirect_uri' => @@callbackuri\
    ,'grant_type' => 'authorization_code' }
    
    #postform = {'code' => code \
    #,'client_id' => 'cef946186caabbc4d8b691b6baa7b6e774bfbfe2cafa8f85709aa51cd89be0a1' \
    #,'client_secret' => '4546026d69bce678d11e85eaf71263d77e4a1f2ad0ab2d12f8f445335bf492a0' \
    #,'redirect_uri' => 'urn:ietf:wg:oauth:2.0:oob'\
    #,'grant_type' => 'authorization_code' }
    
    res = HTTP.headers("Content-Type" => "application/x-www-form-urlencoded")
    .post("https://connect.lockstate.jp/oauth/token", :ssl_context => CTX , :form => postform)
    
    
    #(D)認可サーバーからレスポンス（アクセストークン）受取り
    
    #認証失敗の場合
    if res.code!=200
      @error = res
      @state = "認証に失敗しました"
      render
    #認証成功の場合
    else
      @error = res
      @state = "認証に成功しました"
      json = ActiveSupport::JSON.decode( res.body )
      puts(json)
      
      #アクセストークン
      @@accessToken = json["access_token"]
      puts(@@accessToken)
      
      render
    end
  end
  
  
  #アクセストークンを返す
  def getAccessToken
    return @@accessToken
  end
  
  
  
end
