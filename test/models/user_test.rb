
require "test_helper"

class UserTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  def setup 
    @user = User.new(name: "Example User" , email: "user@example.com" , password: "foobar" , password_confirmation: "foobar")
  end

  test "password should be present (notblank)" do
    @user.password = @user.password_confirmation = " " * 6
    assert_not @user.valid?
  end

  test "password should have a minimun length" do
    @user.password = @user.password_confirmation = "a" * 5
    assert_not @user.valid?
  end
end
