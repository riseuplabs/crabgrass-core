require 'rubygems'
require 'minitest/unit'
require 'minitest/spec'
require 'metaid'
require File.dirname(__FILE__) + '/../../helpers/stub_test_helper'

MiniTest::Unit.autorun

describe MiniTest::Spec do
  describe 'the #stub helper' do
    before do
      @t = Object.new
    end
    it 'should return a working stub object' do
      stub(@t){{ 'bla' => 1 }}
      @t.bla.must_equal 1
    end
  end
  describe PartialStub do
    describe 'the usual stubbing' do
      before do
        @s = Object.new
        @s.extend PartialStub
      end
      it 'should add new methods' do
        @s.stub{{ 'bla' => 1 }}
        @s.bla.must_equal 1
      end
      it 'should add new methods with args' do
        @s.stub{{ 'bla(5)' => 5 }}
        @s.bla(5).must_equal 5
      end
      it 'should take two methods' do
        @s.stub{{ 'bla(4)' => 4, 'bla(5)' => 5 }}
        @s.bla(4).must_equal 4
        @s.bla(5).must_equal 5
      end
      it 'should work with stubs added in to two steps' do
        @s.stub{{ 'bla(4)' => 4 }}
        @s.stub{{ 'bla(5)' => 5 }}
        @s.bla(4).must_equal 4
        @s.bla(5).must_equal 5
      end
      it 'should take methods with and without arguments' do
        @s.stub{{ 'bla' => 2, 'bla(5)' => 5 }}
        @s.bla.must_equal 2
        @s.bla(5).must_equal 5
      end
      it 'should work with more than one argument' do
        @s.stub{{ 'bla(5,3)' => 5 }}
        @s.bla(5,3).must_equal 5
      end
      it 'should work with instance variables as args' do
        @r = 'fu'
        @s.stub{{ 'bla(@r)' => 5 }}
        @s.bla("fu").must_equal 5
      end
      it 'should work with local variables as args' do
        r = 'raa!'
        @s.stub{{ 'blub(r)' => 'b' }}
        @s.blub(r).must_equal 'b'
      end
      it 'should work with instance variables as results' do
        @r = 'fu'
        @s.stub{{ 'bla(1)' => e('@r') }}
        @s.bla(1).must_equal @r
      end
      it 'should work with local variables as results' do
        r = 'raa!'
        @s.stub{{ 'blub(2)' => e('r') }}
        @s.blub(2).must_equal r
      end
      it 'should work with other methods in the result' do
        @s.stub{{ 'r' => 'r1', 's' => 's1', 't' => e('"#{@s.r} and #{@s.s}"') }}
        @s.t.must_equal 'r1 and s1'
      end
      it 'should work with symbols as results' do
        @s.stub{{ 'bra("what")' => :a }}
        @s.bra('what').must_equal :a
      end
      it 'should work with nil as results' do
        @s.stub{{ 'bra("what")' => nil }}
        @s.bra('what').must_equal nil
      end
      it 'should work with demeter calls' do
        @s.stub{{ 'bla(2).blub(3)' => 5 }}
        @s.bla(2).blub(3).must_equal 5
      end
    end
    describe 'with an object with existing methods' do
      before do
        @t = Object.new
        def @t.bla(s)
          "original #{s}"
        end
        @t.extend PartialStub
      end
      it 'be possible to call unstubbed methods' do
        @t.stub{{ 'blub' => 'blub' }}
        @t.bla('hu').must_equal 'original hu'
      end
      it 'should be possible to overwrite methods' do
        @t.stub{{ 'bla' => 'bla' }}
        @t.bla.must_equal 'bla'
      end
      it 'should be possible to overwrite methods defined on the class' do
        @t.stub{{ 'to_s' => 'bla' }}
        @t.to_s.must_equal 'bla'
      end
      it 'should be possible to overwrite methods with certain arguments' do
        @t.stub{{ 'bla(3)' => 'bla' }}
        @t.bla(3).must_equal 'bla'
        @t.bla(4).must_equal 'original 4'
      end
      it 'should be possible to overwrite methods defined on the class with arguments' do
        @t.stub{{ 'to_s(4)' => 'bla' }}
        @t.to_s(4).must_equal 'bla'
        @t.to_s.must_match %r{^#<Object:0x}
      end
    end
    describe 'with existing #method_missing' do
      before do
        @s = Object.new
        def @s.method_missing(name, *args)
          'method_missing!!'
        end
        @s.extend PartialStub
      end
      it 'not overwrite #method_missing' do
        @s.foobar.must_equal 'method_missing!!'
      end
      it 'should still work' do
        @s.stub{{ 'blub(4)' => 'bla' }}
        @s.blub(4).must_equal 'bla'
      end
    end
  end
end
