from lighthouse import Lighthouse

urls = [
    'https://www.ifixit.com',
    'https://www.ifixit.com/Device/Mac',
    'https://www.ifixit.com/Guide/How+Install+a+Mac+SSD+into+an+OWC+Envoy+Pro+Enclosure/120579',
    'https://www.ifixit.com/News/76148/ifixit-has-genuine-parts-for-repairing-hp-laptops',
    'https://www.ifixit.com/Parts',
    'https://www.ifixit.com/Tools',
    'https://www.ifixit.com/Answers',
    'https://www.ifixit.com/Answers/View/791009/How+to+remove+iCloud+Activation+Lock'
]

def main():
    lighthouse = Lighthouse()

    for url in urls:
        try:
            print(f'Running lighthouse for {url}')
            lighthouse.run(url)
            print(f'Finished running lighthouse for {url}')
        except Exception as e:
            print(f'Failed to run lighthouse for {url}: {e}')
            raise e

if __name__ == '__main__':
    main()