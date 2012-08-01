# http://www.pipetodevnull.com/past/2010/4/14/uninitialized_constant_delayedjob/
# prevent `uninitialized constant Delayed::Job`

Delayed::Worker.backend = :active_record
