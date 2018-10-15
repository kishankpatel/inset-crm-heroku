require 'test_helper'

class CommunityPluginsControllerTest < ActionController::TestCase
  setup do
    @community_plugin = community_plugins(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:community_plugins)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create community_plugin" do
    assert_difference('CommunityPlugin.count') do
      post :create, community_plugin: { description: @community_plugin.description, is_active: @community_plugin.is_active, name: @community_plugin.name, price: @community_plugin.price, unique_id: @community_plugin.unique_id }
    end

    assert_redirected_to community_plugin_path(assigns(:community_plugin))
  end

  test "should show community_plugin" do
    get :show, id: @community_plugin
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @community_plugin
    assert_response :success
  end

  test "should update community_plugin" do
    put :update, id: @community_plugin, community_plugin: { description: @community_plugin.description, is_active: @community_plugin.is_active, name: @community_plugin.name, price: @community_plugin.price, unique_id: @community_plugin.unique_id }
    assert_redirected_to community_plugin_path(assigns(:community_plugin))
  end

  test "should destroy community_plugin" do
    assert_difference('CommunityPlugin.count', -1) do
      delete :destroy, id: @community_plugin
    end

    assert_redirected_to community_plugins_path
  end
end
