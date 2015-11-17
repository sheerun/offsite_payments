require 'test_helper'

class TPayHelperTest < Test::Unit::TestCase
  include OffsitePayments::Integrations

  def setup
    @account       = 'test-shop-id'
    @amount        = 123
    @crc           = 'crc'
    @security_code = 'security_code'

    @helper = TPay::Helper.new 'test-order', @account,
      amount:      @amount,
      credential2: @crc,
      credential3: @security_code
  end

  def test_core_fields
    assert_field 'id',     'test-shop-id'
    assert_field 'jezyk',  'PL'
    assert_field 'opis',   'test-order'
    assert_field 'online', '1'
    assert_field 'kwota',  '123'
  end

  def test_customer_fields
    @helper.customer name:  'Test',
                     email: 'test@test.test',
                     phone: '+48 123 456 789'

    assert_field 'nazwisko', 'Test'
    assert_field 'email',    'test@test.test'
    assert_field 'telefon',  '+48 123 456 789'
  end

  def test_address_fields
    @helper.billing_address city:    'Testowo',
                            address: 'Testowa 12/3',
                            zip:     '12-345',
                            country: 'Polska'

    assert_field 'miasto', 'Testowo'
    assert_field 'adres',  'Testowa 12/3'
    assert_field 'kod',    '12-345'
    assert_field 'kraj',   'Polska'
  end

  def test_form_fields
    assert_equal \
      Digest::MD5.hexdigest("#{@account}#{@amount}#{@crc}#{@security_code}"),
      @helper.form_fields['md5sum']
  end
end
