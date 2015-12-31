require 'test_helper'

class RailtieTest < SecondBase::TestCase

  def test_config
    expected = 'db/secondbase'
    assert_equal expected, railtie_inst.config.second_base.path
    assert_equal expected, railtie_klass.config.second_base.path
  end

  def test_fullpath
    expected = dummy_db.join('secondbase').to_s
    assert_equal expected, railtie_inst.fullpath
    assert_equal expected, railtie_klass.fullpath
  end


  private

  def railtie_inst
    dummy_app.railties.grep(railtie_klass).first
  end

  def railtie_klass
    SecondBase::Railtie
  end

end
