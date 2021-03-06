---
layout: default
title: Resty,  Objective-C REST Resource consumption made easy
---

Resty is a simple to use HTTP library for Cocoa and iOS apps, aimed at consuming RESTful web services and APIs. 

It uses modern Objective-C language features like blocks to simple asynchronous requests without having to worry about threads, operation queues or repetitive delegation. It is inspired heavily by [RestClient](http://github.com/archiloque/rest-client), a Ruby HTTP library.

{% ultrahighlight objective-c %}
- (void)fetchSomething
{
  [[LRResty client] get:@"http://www.example.com" withBlock:^(LRRestyResponse *r) {
    NSLog(@"That's it! %@", [r asString]);
  }];
}
{% endultrahighlight %}

<div class="download">
  <a href="http://github.com/downloads/lukeredpath/LRResty/LRResty-0.9.dmg">Download the latest version of LRResty.framework (0.9)</a>
  
  <div class="notice">
    This website isn't quite finished, so some things may be broken or incomplete.
  </div>
  
  <p class="license">Resty is released under the <a href="http://en.wikipedia.org/wiki/MIT_License">MIT license</a>.</p>
</div>

