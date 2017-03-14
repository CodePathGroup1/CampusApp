# Project 5 - *CampusApp*

Campus app aimed to bring students together as a community.

Time spent: **X** hours spent in total

## User Stories

The following **required** functionality is completed:

- [ ] User can sign up, log in, and log out with custom backend
- [ ] User can see feed of CCSF events
	Events include:
	- [ ] Event titles
	- [ ] Event time or time til
	- [ ] Event campus, building, and room when applicable
- [ ] User can navigate to a detail view of events that includes:
	- [ ] Event info
	- [ ] Event description
	- [ ] Map view
- [ ] User can persist across restarts
- [ ] User can save preferences in a settings controller
	- [ ] UI settings
	- [ ] Set which campus(es) to see events for


**Optional**


## Video Walkthrough 

Here's a walkthrough of implemented user stories:

<img src='http://i.imgur.com/link/to/your/gif/file.gif' title='Video Walkthrough' width='' alt='Video Walkthrough' />

GIF created with [LiceCap](http://www.cockos.com/licecap/).

## WIREFRAME:

Describe any challenges encountered while building the app.


![campuswireframe](https://cloud.githubusercontent.com/assets/12878483/23820245/7c364ee2-05c9-11e7-8319-aa0f12186e37.png)


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
- type  (To differentiate between “event” and “class” types if/when we introduce support for classes)



## License

    Copyright [2017] [Thomas Zhu & Hannah Lily Postman & Mitchell Wong]

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
