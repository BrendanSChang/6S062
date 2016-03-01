import math

def calcDistance(path):
    # Read the file.
    f = open(path, 'r')

    # Split the lines of the file into coordinate fields (LatLng pairs).
    # The first line of the file is the header and data starts on the
    # second line.
    lines = f.read().split()

    # Header is assumed to be:
    # 'Time,Lat,Lon,Altitude,Accuracy,Heading,Speed,Battery'
    # print 'Header: %s' % lines[0]
    latlngs = []
    for l in lines[1:]:
        fields = l.split(',')

        # Convert LatLngs to radians.
        latlngs.append(
            [float(fields[1])*math.pi/180, float(fields[2])*math.pi/180]
        )

    # Distance of the earth in kilometers.
    r = 6371

    # Get the first pair of coordinates.
    lat1 = latlngs[0][0]
    lon1 = latlngs[0][1]

    distance = 0
    for pair in latlngs[1:]:
        # Get the second pair of coordinates.
        lat2 = pair[0]
        lon2 = pair[1]
        
        # Calculate the distance between the two points using the
        # haversine formula.
        d = 2*r*math.asin(
	        math.sqrt(
                    (math.sin((lat2-lat1)/2)**2) +
                    math.cos(lat1)*math.cos(lat2)*(math.sin((lon2-lon1)/2)**2)
                )
	    )

        distance += d

        # Reset the first coordinate pair.
        lat1 = lat2
        lon1 = lon2

    return distance

if __name__ == '__main__':
    print 'Calculating the distances for the collected GPS, ' + \
               'Cellular, and WiFi data'
    print

    # Assumes that this code is being run from within the directory containing
    # the location data.
    files = ['GPS.csv', 'CELL.csv', 'WIFI.csv']
    for f in files:
        print 'Distance calculated for %s: %f' % (f, calcDistance(f))
