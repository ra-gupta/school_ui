require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(name: "Platform Admin", email_address: "admin@erp.test",
                         phone: "+919012345678", kind: "super_admin", password: "password")
  end

  test "new" do
    get new_session_path
    assert_response :success
  end

  test "create with an email address" do
    post session_path, params: { login: @user.email_address, password: "password" }

    assert_redirected_to root_path
    assert cookies[:session_id]
  end

  test "create with a mobile number" do
    post session_path, params: { login: @user.phone, password: "password" }

    assert_redirected_to root_path
    assert cookies[:session_id]
  end

  # What a parent actually types: the ten digits they know, no country code.
  test "create with a mobile number typed without a country code" do
    post session_path, params: { login: "90123 45678", password: "password" }

    assert_redirected_to root_path
    assert cookies[:session_id]
  end

  test "create with invalid credentials" do
    post session_path, params: { login: @user.email_address, password: "wrong" }

    assert_redirected_to new_session_path(login: @user.email_address)
    assert_nil cookies[:session_id]
  end

  test "create is refused for a deactivated account" do
    @user.update!(active: false)
    post session_path, params: { login: @user.phone, password: "password" }

    assert_nil cookies[:session_id]
  end

  test "destroy" do
    sign_in_as(@user)

    delete session_path

    assert_redirected_to new_session_path
    assert_empty cookies[:session_id]
  end
end
