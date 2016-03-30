import matplotlib.pyplot as plt

def makeGraph(path):
    f = open(path, 'r')
    lines = f.read().split()
    
    timestamps = []
    battery = []
    for line in lines[1:]:
        fields = line.split(',')
        timestamps.append(float(fields[0]))
        battery.append(float(fields[-1]))
    
    plt.plot(timestamps, battery)
    plt.show()

if __name__ == '__main__':
    print 'Making the battery drain graphs for the collected GPS, ' + \
               'Cellular, and WiFi data'
    print

    # Assumes that this code is being run from within the directory containing
    # the battery drain data data.
    files = ['GPS.csv', 'CELL.csv', 'WIFI.csv']
    for f in files:
        makeGraph(f)