# HomeAssistant::Generator

[![Build Status](https://travis-ci.org/kamaradclimber/home_assistant-generator.svg?branch=master)](https://travis-ci.org/kamaradclimber/home_assistant-generator)
[![Gem Version](https://badge.fury.io/rb/home_assistant-generator.svg)](https://badge.fury.io/rb/home_assistant-generator)

This gem is used to easily generate home-assistant configuration.
By default, home-assistant configuration is written in yaml format.

This gem provides a simple DSL to write configuration in a better format.

### Notice

This gem is a work in progress and might not be usable nor being maintained for long. Use if if you like it.

## Usage

Install the gem using `gem install home_assistant-generator`.

Define your configuration with the dsl in a file (let's call it myconfig.rb).

Then, `hass-generator myconfig.rb` should produce a workable yaml configuration for home-assistant.

## Contributions

Create an issue to state the missing feature, the bug or the improvement. Then submit a PR.
