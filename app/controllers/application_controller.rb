class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  #ログインに関するヘルパーメソッドを全てのコントローラーで使用できるようにするにはここでmoduleをincludeすればいい
  include SessionsHelper
end
