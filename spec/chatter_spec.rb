require 'chatter'

describe Chatter do
  before(:each) do
    @chatter = Class.new
    @chatter.send(:attr_accessor, :value)
    @chatter.extend Chatter
  end

  def any_value
    rand
  end

  def any_function
    r = rand(100)
    proc do |*a|
      a.reverse * r
    end
  end

  def any_method_name
    :"test_method_#{rand(100)}"
  end

  it "should define the method using block when only one sub-method" do
    v = any_value
    m = any_method_name
    @chatter.chat(m) {v}
    @chatter.new.send(m).should == v
  end

  it "should evaluate method block in instance scope" do
    v = any_value
    m = any_method_name
    @chatter.chat(m) {@value}
    @chatter.new.tap {|o| o.value = v}.send(m).should == v
  end

  it "should combine multiple sub-methods to function like one method" do
    method_body = any_function
    (m1, m2, m3) = Array.new(3) {any_method_name}
    (v1, v2, v3) = Array.new(3) {any_value}
    @chatter.chat(m1, m2, m3, &method_body)
    @chatter.send(:define_method, :equiv_method, &method_body)
    @chatter.new.tap do |o|
      o.send(m1, v1).send(m2, v2).send(m3, v3).should ==
        o.equiv_method(v1, v2, v3)
    end
  end

  it "should handle partly overlapping sub-methods" do
    pending('Overlapping sub-methods not implemented yet')
    (body1, body2) = Array.new(2) {any_function}
    (m0, m1, m2) = Array.new(3) {any_method_name}
    (v0, v1, v2) = Array.new(3) {any_value}
    @chatter.chat(m0, m1, &body1)
    @chatter.chat(m0, m2, &body2)
    @chatter.new.tap do |o|
      o.send(m0, v0).send(m1, v1).should == body1.call(v0, v1)
      o.send(m0, v0).send(m2, v2).should == body2.call(v0, v2)
    end
  end

  it "should handle sub-method blocks" do
    pending('Sub-method blocks not implemented yet')
    (t, f) = Array.new(3) {any_value}
    # tentative syntax
    @chatter.chat(:'ifValueTrue(&t_block)', :'ifValueFalse(&f_block)') do
      if @value
        t_block.call
      else
        f_block.call
      end
    end
    @chatter.new {@value = false}.
      ifValueTrue {t}.ifValueFalse {f}.should == 'correct'
  end
end
   
