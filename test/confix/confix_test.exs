defmodule ConfixTest do
  use ExUnit.Case
  alias Confix.KeyError

  describe "__using__/1" do
    test "defines config helpers" do
      defmodule ConfixTestMod do
        use Confix
      end

      assert ConfixTestMod.config(:key) == :value
      assert ConfixTestMod.config([:nest_key, :nest_value]) == :deep_value

      assert_raise KeyError, fn ->
        ConfixTestMod.config!([:nest_key, :missing_nest_value])
      end
    end
  end

  describe "get/2" do
    test "gets flat config" do
      assert Confix.get(:flat_config_key) == "flat value"
    end
  end

  describe "get!/2" do
    test "gets flat config" do
      assert Confix.get!(:flat_config_key) == "flat value"
    end

    test "raises for nil" do
      assert_raise KeyError, fn ->
        Confix.get!(:flat_config_key_missing)
      end
    end

    test "doesn't raise for false" do
      assert Confix.get!(:flat_config_key_false) == false
    end
  end

  describe "get_in/2" do
    test "gets nested config" do
      assert Confix.get_in([:config_test, :filled_key]) == "filled value"
      assert Confix.get_in([:config_test, :system_key_without_default]) == nil
      assert Confix.get_in([:config_test, :system_key_with_default]) == "default value"
    end
  end

  describe "get_in!/2" do
    test "gets nested config" do
      assert Confix.get_in!([:config_test, :filled_key]) == "filled value"
      assert Confix.get_in!([:config_test, :system_key_with_default]) == "default value"
    end

    test "raises for nil" do
      assert_raise KeyError, fn ->
        Confix.get_in!([:config_test, :system_key_without_default])
      end
    end
  end

  describe "parse/1" do
    test "parses flat values" do
      assert Confix.parse("value") == "value"
    end

    test "parses system tuples" do
      assert Confix.parse({:system, "NON_EXISTING_ENV_VAR"}) == nil
    end

    test "parses system tuples with a list of vars" do
      System.put_env("EXISTING_ENV_VAR_1", "A")
      System.put_env("EXISTING_ENV_VAR_2", "B")

      assert Confix.parse({:system, ["NON_EXISTING_ENV_VAR_1", "NON_EXISTING_ENV_VAR_2"]}) == nil

      assert Confix.parse(
               {:system,
                [
                  "NON_EXISTING_ENV_VAR_1",
                  "EXISTING_ENV_VAR_1",
                  "EXISTING_ENV_VAR_2"
                ]}
             ) == "A"
    end

    test "parses system tuples with a default" do
      System.put_env("EXISTING_ENV_VAR", "value")

      assert Confix.parse({:system, "EXISTING_ENV_VAR", default: "default value"}) ==
               "value"

      assert Confix.parse({:system, "NON_EXISTING_ENV_VAR", default: "default value"}) ==
               "default value"
    end

    test "parses boolean system tuples" do
      System.put_env("BOOLEAN_ENV_VAR", "0")
      assert Confix.parse({:system, "BOOLEAN_ENV_VAR", type: :boolean}) == false
      System.put_env("BOOLEAN_ENV_VAR", "1")
      assert Confix.parse({:system, "BOOLEAN_ENV_VAR", type: :boolean}) == true
    end

    test "parses integer system tuples" do
      System.put_env("INTEGER_ENV_VAR", "0")
      assert Confix.parse({:system, "INTEGER_ENV_VAR", type: :integer}) == 0
      System.put_env("INTEGER_ENV_VAR", "1")
      assert Confix.parse({:system, "INTEGER_ENV_VAR", type: :integer}) == 1
      System.put_env("INTEGER_ENV_VAR", "-42")
      assert Confix.parse({:system, "INTEGER_ENV_VAR", type: :integer}) == -42
    end
  end
end
