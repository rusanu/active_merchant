require 'test_helper'

class QuickBooksTest < Test::Unit::TestCase
  def setup
    @gateway = QuickbooksGateway.new(
      options = {
      consumer_key: 'consumer_key',
      consumer_secret: 'consumer_secret',
      access_token: 'access_token',
      token_secret: 'token_secret',
      realm: 'realm_ID',
    }
    )

    @credit_card = credit_card
    @amount = 100

    @options = {
      order_id: '1',
      billing_address: address,
      description: 'Store Purchase'
    }

    @authorization = "ECZ7U0SO423E"
  end

  def test_successful_purchase
    @gateway.expects(:ssl_post).returns(successful_purchase_response)
    response = @gateway.purchase(@amount, @credit_card, @options)
    assert_success response

    assert_equal "EF1IQ9GGXS2D", response.authorization
    assert response.test?
  end

  def test_failed_purchase
    @gateway.expects(:ssl_post).returns(failed_purchase_response)

    response = @gateway.purchase(@amount, @credit_card, @options)
    assert_failure response
    assert_equal Gateway::STANDARD_ERROR_CODE[:card_declined], response.error_code
  end

  def test_successful_authorize
    @gateway.expects(:ssl_post).returns(successful_authorize_response)
    response = @gateway.authorize(@amount, @credit_card, @options)
    assert_success response

    assert_equal @authorization, response.authorization
    assert response.test?
  end

  def test_failed_authorize
    @gateway.expects(:ssl_post).returns(failed_purchase_response)

    response = @gateway.authorize(@amount, @credit_card, @options)
    assert_failure response
    assert_equal Gateway::STANDARD_ERROR_CODE[:card_declined], response.error_code
  end

  def test_successful_capture
    @gateway.expects(:ssl_post).returns(successful_capture_response)

    response = @gateway.capture(@amount, @authorization)
    assert_success response
  end

  def test_failed_capture
  end

  def test_successful_refund
  end

  def test_failed_refund
  end

  def test_successful_void
  end

  def test_failed_void
  end

  def test_successful_verify
  end

  def test_successful_verify_with_failed_void
  end

  def test_failed_verify
  end

  def test_scrub
    assert @gateway.supports_scrubbing?
    assert_equal @gateway.send(:scrub, pre_scrubbed), post_scrubbed
  end

  private

  def successful_purchase_response
    <<-RESPONSE
    {
      "created": "2014-11-27T22:09:01Z",
      "status": "CAPTURED",
      "amount": "20.00",
      "currency": "USD",
      "card": {
        "number": "xxxxxxxxxxxx1111",
        "name": "alicks profit",
        "address": {
          "city": "xxxxxxxx",
          "region": "xx",
          "country": "xx",
          "streetAddress": "xxxxxxxxxxxxx",
          "postalCode": "xxxxx"
        },
        "expMonth": "01",
        "expYear": "2021"
      },
      "id": "EF1IQ9GGXS2D",
      "authCode": "664472",
      "capture": "true"
    }
    RESPONSE
  end

  def failed_purchase_response
    <<-RESPONSE
    {
      "errors":[{
        "code": "PMT-5000",
        "type": "invalid_request",
        "message": "he request to process this transaction has been declined.",
        "detail": "Amount.",
        "infoLink": "https://developer.intuit.com/v2/docs?redirectID=PayErrors"
      }]
    }
    RESPONSE
  end

  def successful_authorize_response
    <<-RESPONSE
    {
      "created": "2014-11-27T22:17:22Z",
      "status": "AUTHORIZED",
      "amount": "2000.00",
      "currency": "USD",
      "card": {
        "number": "xxxxxxxxxxxx4242",
        "name": "alicks profit",
        "address": {
          "city": "xxxxxxxx",
          "region": "xx",
          "country": "xx",
          "streetAddress": "xxxxxxxxxxxxx",
          "postalCode": "xxxxx"
        },
        "expMonth": "01",
        "expYear": "2021"
      },
      "capture": false,
      "id": "ECZ7U0SO423E",
      "authCode": "279714"
    }
    RESPONSE
  end

  def failed_authorize_response
    <<-RESPONSE
    {
      "errors":[{
        "code": "PMT-5000",
        "type": "invalid_request",
        "message": "he request to process this transaction has been declined.",
        "detail": "Amount.",
        "infoLink": "https://developer.intuit.com/v2/docs?redirectID=PayErrors"
      }]
    }
    RESPONSE
  end

  def successful_capture_response
    <<-RESPONSE
    {
      "created": "2014-12-17T22:39:21Z",
      "status": "CAPTURED",
      "amount": "10.55",
      "currency": "USD",
      "card": {
        "number": "xxxxxxxxxxxx4444",
        "cvc": "xxx",
        "name": "emulate=0",
        "address": {
          "city": "xxxxxxxxx",
          "region": "xx",
          "country": "xx",
          "streetAddress": "xxxxxxxxxxxxx",
          "postalCode": "xxxxx"
        },
        "expMonth": "02",
        "expYear": "2020"
      },
      "id": "ELFWEU8LS00K",
      "authCode": "537265"
    }
    RESPONSE
  end

  def failed_capture_response
    <<-RESPONSE
    {
      "errors":[{
        "code": "PMT-5000",
        "type": "invalid_request",
        "message": "he request to process this transaction has been declined.",
        "detail": "Amount.",
        "infoLink": "https://developer.intuit.com/v2/docs?redirectID=PayErrors"
      }]
    }
    RESPONSE
  end

  def successful_refund_response
  end

  def failed_refund_response
    <<-RESPONSE
    {
      "errors":[{
        "code": "PMT-5000",
        "type": "invalid_request",
        "message": "he request to process this transaction has been declined.",
        "detail": "Amount.",
        "infoLink": "https://developer.intuit.com/v2/docs?redirectID=PayErrors"
      }]
    }
    RESPONSE
  end

  def successful_void_response
  
  end

  def failed_void_response
    <<-RESPONSE
    {
      "errors":[{
        "code": "PMT-5000",
        "type": "invalid_request",
        "message": "he request to process this transaction has been declined.",
        "detail": "Amount.",
        "infoLink": "https://developer.intuit.com/v2/docs?redirectID=PayErrors"
      }]
    }
    RESPONSE
  end
end
