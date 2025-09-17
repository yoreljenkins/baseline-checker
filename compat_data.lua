-- Browser compatibility data module
-- This module manages compatibility data for CSS properties and values

local M = {}

M.css_compatibility = {
  ['grid-template-columns'] = {
    baseline = true,
    support = {
      chrome = '57',
      firefox = '52',
      safari = '10.1',
      edge = '16'
    },
    status = 'supported',
    description = 'The grid-template-columns CSS property defines the line names and track sizing functions of the grid columns.'
  },
  ['container-queries'] = {
    baseline = false,
    support = {
      chrome = '105',
      firefox = '110',
      safari = '16.0',
      edge = '105'
    },
    status = 'limited',
    description = 'Container queries allow you to apply styles based on the size of a containing element rather than the viewport.'
  },
  ['subgrid'] = {
    baseline = false,
    support = {
      chrome = 'none',
      firefox = '71',
      safari = '16.0',
      edge = 'none'
    },
    status = 'experimental',
    description = 'The subgrid value for grid-template-columns and grid-template-rows allows nested grids to use their parent grid\'s tracks.'
  },
  ['display'] = {
    baseline = true,
    support = {
      chrome = '1',
      firefox = '1',
      safari = '1',
      edge = '12'
    },
    status = 'supported',
    description = 'The display CSS property sets whether an element is treated as a block or inline element.'
  },
  ['flex'] = {
    baseline = true,
    support = {
      chrome = '29',
      firefox = '28',
      safari = '9',
      edge = '12'
    },
    status = 'supported',
    description = 'The flex CSS shorthand property sets how a flex item will grow or shrink.'
  },
  ['gap'] = {
    baseline = true,
    support = {
      chrome = '84',
      firefox = '63',
      safari = '14.1',
      edge = '84'
    },
    status = 'supported',
    description = 'The gap CSS property sets the gaps between rows and columns in grid, flexbox, and multi-column layouts.'
  },
  ['container-type'] = {
    baseline = false,
    support = {
      chrome = '105',
      firefox = '110',
      safari = '16.0',
      edge = '105'
    },
    status = 'limited',
    description = 'The container-type CSS property establishes the element as a query container for container queries.'
  },
  ['aspect-ratio'] = {
    baseline = true,
    support = {
      chrome = '88',
      firefox = '89',
      safari = '15',
      edge = '88'
    },
    status = 'supported',
    description = 'The aspect-ratio CSS property sets a preferred aspect ratio for the box.'
  },
  ['backdrop-filter'] = {
    baseline = false,
    support = {
      chrome = '76',
      firefox = '103',
      safari = '9',
      edge = '17'
    },
    status = 'limited',
    description = 'The backdrop-filter CSS property applies graphical effects such as blurring or color shifting to the area behind an element.'
  },
  ['grid'] = {
    baseline = true,
    support = {
      chrome = '57',
      firefox = '52',
      safari = '10.1',
      edge = '16'
    },
    status = 'supported',
    description = 'The grid CSS property is a shorthand that sets all the explicit and implicit grid properties.'
  },
  ['transition'] = {
    baseline = true,
    support = {
      chrome = '26',
      firefox = '16',
      safari = '9',
      edge = '12'
    },
    status = 'supported',
    description = 'The transition CSS property is a shorthand property for transition-property, transition-duration, transition-timing-function, and transition-delay.'
  },
  ['transform'] = {
    baseline = true,
    support = {
      chrome = '36',
      firefox = '16',
      safari = '9',
      edge = '12'
    },
    status = 'supported',
    description = 'The transform CSS property lets you rotate, scale, skew, or translate an element.'
  },
  ['border-radius'] = {
    baseline = true,
    support = {
      chrome = '4',
      firefox = '4',
      safari = '5',
      edge = '12'
    },
    status = 'supported',
    description = 'The border-radius CSS property rounds the corners of an element\'s outer border edge.'
  },
  ['box-shadow'] = {
    baseline = true,
    support = {
      chrome = '10',
      firefox = '4',
      safari = '5.1',
      edge = '12'
    },
    status = 'supported',
    description = 'The box-shadow CSS property adds shadow effects around an element\'s frame.'
  },
  ['opacity'] = {
    baseline = true,
    support = {
      chrome = '1',
      firefox = '1',
      safari = '2',
      edge = '12'
    },
    status = 'supported',
    description = 'The opacity CSS property sets the opacity of an element.'
  },
  ['position'] = {
    baseline = true,
    support = {
      chrome = '1',
      firefox = '1',
      safari = '1',
      edge = '12'
    },
    status = 'supported',
    description = 'The position CSS property sets how an element is positioned in a document.'
  },
  ['color'] = {
    baseline = true,
    support = {
      chrome = '1',
      firefox = '1',
      safari = '1',
      edge = '12'
    },
    status = 'supported',
    description = 'The color CSS property sets the foreground color value of an element\'s text and text decorations.'
  },
  ['background'] = {
    baseline = true,
    support = {
      chrome = '1',
      firefox = '1',
      safari = '1',
      edge = '12'
    },
    status = 'supported',
    description = 'The background shorthand CSS property sets all background style properties at once.'
  },
  ['margin'] = {
    baseline = true,
    support = {
      chrome = '1',
      firefox = '1',
      safari = '1',
      edge = '12'
    },
    status = 'supported',
    description = 'The margin CSS property sets the margin area on all four sides of an element.'
  },
  ['padding'] = {
    baseline = true,
    support = {
      chrome = '1',
      firefox = '1',
      safari = '1',
      edge = '12'
    },
    status = 'supported',
    description = 'The padding CSS property sets the padding area on all four sides of an element at once.'
  },
  ['width'] = {
    baseline = true,
    support = {
      chrome = '1',
      firefox = '1',
      safari = '1',
      edge = '12'
    },
    status = 'supported',
    description = 'The width CSS property sets an element\'s width.'
  },
  ['height'] = {
    baseline = true,
    support = {
      chrome = '1',
      firefox = '1',
      safari = '1',
      edge = '12'
    },
    status = 'supported',
    description = 'The height CSS property specifies the height of an element.'
  },
  ['font-size'] = {
    baseline = true,
    support = {
      chrome = '1',
      firefox = '1',
      safari = '1',
      edge = '12'
    },
    status = 'supported',
    description = 'The font-size CSS property sets the size of the font.'
  },
  ['font-family'] = {
    baseline = true,
    support = {
      chrome = '1',
      firefox = '1',
      safari = '1',
      edge = '12'
    },
    status = 'supported',
    description = 'The font-family CSS property specifies a prioritized list of one or more font family names.'
  }
}

function M.get_property_info(property)
  local local_info = M.css_compatibility[property]
  if local_info then
    return local_info
  end

  local api = require('baseline-checker.api')
  local feature_data = api.fetch_feature_by_id(property)
  if feature_data and feature_data.features and #feature_data.features > 0 then
    local feature = feature_data.features[1] -- Get the first feature from the response
    local compat_data = api.convert_webstatus_feature_to_compat_data(feature)
    if compat_data then
      M.css_compatibility[property] = compat_data
      return compat_data
    end
  end

  return nil
end

function M.update_property(property, data)
  M.css_compatibility[property] = data
end

function M.update_from_api()
  local api = require('baseline-checker.api')
  local common_features = {
    'grid', 'flexbox', 'container-queries', 'aspect-ratio',
    'backdrop-filter', 'subgrid', 'gap', 'display'
  }

  local updated_count = 0
  for _, feature in ipairs(common_features) do
    local feature_data = api.fetch_feature_by_id(feature)
    if feature_data and feature_data.features and #feature_data.features > 0 then
      local single_feature = feature_data.features[1] -- Get the first feature from the response
      local compat_data = api.convert_webstatus_feature_to_compat_data(single_feature)
      if compat_data then
        M.update_property(feature, compat_data)
        updated_count = updated_count + 1
      end
    end
  end

  print(string.format('Updated %d CSS properties from web.dev API', updated_count))
  return updated_count
end

function M.load_from_api_data(features_data)
  if not features_data then
    return 0
  end

  local api = require('baseline-checker.api')
  local updated_count = 0

  for feature_id, feature in pairs(features_data) do
    local compat_data = api.convert_webstatus_feature_to_compat_data(feature)
    if compat_data then
      M.css_compatibility[feature_id] = compat_data
      updated_count = updated_count + 1
    end
  end

  print(string.format('Loaded %d features from API data', updated_count))
  return updated_count
end

function M.load_from_json_file()
  local api = require('baseline-checker.api')
  local features_data = api.load_features_from_json()

  if features_data then
    return M.load_from_api_data(features_data)
  else
    print('No local JSON data found')
    return 0
  end
end

function M.initialize()
  local loaded_count = M.load_from_json_file()

  if loaded_count > 0 then
    print(string.format('Initialized with %d features from local JSON data', loaded_count))
  else
    print('Using hardcoded compatibility data (run :BaselineUpdate to fetch latest data)')
  end
end

function M.is_baseline(property)
  local info = M.get_property_info(property)
  return info and info.baseline or false
end

function M.get_support_status(property)
  local info = M.get_property_info(property)
  if not info then
    return 'unknown'
  end
  return info.status
end

function M.get_all_properties()
  local properties = {}
  for prop, _ in pairs(M.css_compatibility) do
    table.insert(properties, prop)
  end
  return properties
end

function M.search_properties(pattern)
  local matches = {}
  for prop, info in pairs(M.css_compatibility) do
    if string.match(prop, pattern) then
      matches[prop] = info
    end
  end
  return matches
end

return M
