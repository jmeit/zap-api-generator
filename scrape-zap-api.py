import scrapy
import re
import json

endpoints = {}

class ZapSpider(scrapy.Spider):
    name = 'zapapi'
    start_urls = ['http://localhost:8081/UI/']


    def parse(self, response):
        for title in response.css('h3'):
            yield {'title': title.css('::text').get()}

        params = []
        for input in response.css('input'):
            if input.attrib['id'] != 'button':
                required = False
                for label in response.css('td'):
                    if label.css('::text').get() == f"{input.attrib['name']}*":
                        required = True
                        break
                params.append( { "name": input.attrib['name'], "required": required } )
            else:
                zap_component = input.attrib['zap-component']
                zap_type = input.attrib['zap-type']
                zap_name = input.attrib['zap-name']
                endpoints.setdefault( zap_component, {} )
                endpoints[ zap_component ][ zap_name ] = { "type": zap_type, "params": params }

        for next_page in response.css('a'):
            href = next_page.attrib['href']
            if re.match( "/UI/.+", href ) and not href in response.url :
                yield response.follow(next_page, self.parse)


    def closed(self, reason):
        with open( "zap-api.json", 'w' ) as f:
                f.write( json.dumps( endpoints, indent=4, sort_keys=True ) )
