require 'test_helper'

class BrochuresControllerTest < ActionDispatch::IntegrationTest
  setup do
    @brochure = brochures(:one)
  end

  test "should get index" do
    get brochures_url
    assert_response :success
  end

  test "should get new" do
    get new_brochure_url
    assert_response :success
  end

  test "should create brochure" do
    assert_difference('Brochure.count') do
      post brochures_url, params: { brochure: {  } }
    end

    assert_redirected_to brochure_url(Brochure.last)
  end

  test "should show brochure" do
    get brochure_url(@brochure)
    assert_response :success
  end

  test "should get edit" do
    get edit_brochure_url(@brochure)
    assert_response :success
  end

  test "should update brochure" do
    patch brochure_url(@brochure), params: { brochure: {  } }
    assert_redirected_to brochure_url(@brochure)
  end

  test "should destroy brochure" do
    assert_difference('Brochure.count', -1) do
      delete brochure_url(@brochure)
    end

    assert_redirected_to brochures_url
  end
end
