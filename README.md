# OpenERP Integration

This is a fully hosted and supported integration for use with the
[FlowLink](http://flowlink.io/) product. With this integration you can perform the
following functions:

* Send orders to OpenERP
* Update existing orders on OpenERP

# Usage

In Odoo, make sure the following is true:

* The Inventory and Sales apps are both installed and active
* You have created products (within the Inventory apps) with internal reference
codes that match the products in the orders you'll be sending
* If you're using an Odoo Online instance, make sure that you check out the
[warning / advice](https://www.odoo.com/documentation/10.0/api_integration.html)
about resetting the password on the user you want to use for XML-RPC access

Within FlowLink, you'll need to setup a Connection using your Odoo URL and
database name, as well as the username and password for the user you setup
above for XML-RPC access.

# About FlowLink

[FlowLink](http://flowlink.io/) allows you to connect to your own custom integrations.
Feel free to modify the source code and host your own version of the integration
or better yet, help to make the official integration better by submitting a pull request!

This integration is 100% open source an licensed under the terms of the New BSD License.

![FlowLink Logo](http://flowlink.io/wp-content/uploads/logo-1.png)
