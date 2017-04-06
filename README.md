# Project 5 - *CampusApp*

Campus app aimed to bring students together as a community.

Time spent: **X** hours spent in total

## User Stories

The following **required** functionality is completed:

- [X] User can sign up, log in, and log out with custom backend
- [X] User can see feed of CCSF events
	Events include:
	- [X] Event titles
	- [X] Event time or time til
	- [X] Event campus, building, and room when applicable
- [X] User can navigate to a detail view of events that includes:
	- [X] Event info
	- [X] Event description
	- [ ] Map view
- [X] User can persist across restarts
- [ ] User can save preferences in a settings controller
	- [ ] UI settings
	- [ ] Set which campus(es) to see events for
- [X] User can create new events
- [X] User can edit existing events (only if it's created by him- or herself
- [X] User can favorite or unfavorite events
- [X] Navigation controller and tab controller have been introduced.


**Optional**

- [X] Facebook signup and login
- [X] Sign up using email and password
- [X] Chat
    - [X] Live (no timer is used)
    - [X] Sending picture and video is supported
    - [X] UI modifications

## Video Walkthrough 

Here's a walkthrough of implemented user stories:

Spring #1
<img src='http://i.imgur.com/PQGovYO.gif' title='Spring 1' width='' alt='Video Walkthrough' />

Spring #2
<img src='http://i.imgur.com/O9BX6bK.gif' title='Spring 2' width='' alt='Video Walkthrough' />

GIF created with [LiceCap](http://www.cockos.com/licecap/).

## WIREFRAME:

Describe any challenges encountered while building the app.


![wireframe](https://cloud.githubusercontent.com/assets/12878483/23884712/8f5feaaa-082b-11e7-9083-fbaf96757373.png)


## Data Schema

#### User (student, organization, etc.)
- ID
- Name
- Email
- List of event IDs

#### Campus
- ID
- Name
- Geo info (latitude, longitude)

#### Building
- ID
- Name
- CampusID
- Geo (latitude, longitude)

#### Room
- ID
- Name
- Building ID

#### Event
- ID
- Start
- End
- Name
- CampusID (because not all events occur in a building)
- BuildingID (because not all events occur in a room)
- RoomID
- Attendees - so that we can track and present number of attendees
- Type  (To differentiate between “event” and “class” types if/when we introduce support for classes)



## License

    Copyright [2017] [Thomas Zhu & Mitchell Wong]

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
