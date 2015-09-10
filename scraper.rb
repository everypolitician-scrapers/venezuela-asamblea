#!/bin/env ruby
# encoding: utf-8

require 'scraperwiki'
require 'nokogiri'
require 'colorize'
require 'pry'
require 'open-uri/cached'
OpenURI::Cache.cache_path = '.cache'

class String
  def tidy
    self.gsub(/[[:space:]]+/, ' ').strip
  end
end

def noko_for(url)
  Nokogiri::HTML(open(url).read)
end

def scrape_list(url)
  puts url
  noko = noko_for(url)
  noko.css('td.linkdip').each do |td|
    data = { 
      id: td.css('b a/@href').text.split('/').last,
      name: td.css('b a').text.strip,
      image: td.xpath('preceding-sibling::td[div[@id="sombra"]]//img/@src').text,
      area: td.css('a#linkestado[href*="/estado/"]').text.sub('Estado:',''),
      area_id: td.css('a#linkestado[href*="/estado/"]/@href').text.split('/').last,
      party: td.css('a#linkestado[href*="/partido/"]').text.sub('Partido:',''),
      party_id: td.css('a#linkestado[href*="/partido/"]/@href').text.split('/').last,
      term: 2015,
      source: td.css('b a/@href').text,
    }
    data[:image] = URI.join(url, data[:image]).to_s unless data[:image].to_s.empty?
    data[:source] = URI.join(url, data[:source]).to_s unless data[:source].to_s.empty?
    ScraperWiki.save_sqlite([:id, :term], data)
  end 
end

(1..14).each { |i| scrape_list("http://asambleanacional.gob.ve/diputado/ajaxcargardiputados/tipodiputado/1/page/#{i}") }
