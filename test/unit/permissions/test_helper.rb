unless defined? Rails
  Rails = stub(root: Pathname.new(__FILE__) + '../../../..' )
end
